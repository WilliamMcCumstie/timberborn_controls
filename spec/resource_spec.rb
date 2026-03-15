require "spec_helper"

RSpec.describe Resource do
  let(:manager) { ResourceManager.new }
  let(:resource) { manager.logs }

  describe "#name" do
    it "exposes the building name" do
      expect(resource.name).to eq("logs")
    end
  end

  describe "#prefix" do
    it "comes from the manager" do
      expect(resource.prefix).to eq(Config::RESOURCE_PREFIX)
    end
  end

  describe "#low" do
    it "returns the low adapter state" do
      expect(resource.low).to be(true).or be(false)
    end
  end

  describe "#high" do
    it "returns the high adapter state" do
      expect(resource.high).to be(true).or be(false)
    end
  end

  describe "#switch_on" do
    it "switches the manufacturing lever on" do
      expect(resource.switch_on).to be true
    end
  end

  describe "#switch_off" do
    it "switches the manufacturing lever off" do
      expect(resource.switch_off).to be true
    end
  end

  describe "#set_color" do
    it "switches the status lever on and sets the colour" do
      FakeTimberborn.levers["P:logs:S"]["state"] = false
      resource.set_color("ff0000")
      expect(FakeTimberborn.levers["P:logs:S"]["state"]).to be true
      expect(FakeTimberborn.levers["P:logs:S"]["color"]).to eq("ff0000")
    end
  end

  describe "status color helpers" do
    it "defines STATUS_COLORS" do
      expect(Resource::STATUS_COLORS[:error]).to eq("ff0000")
      expect(Resource::STATUS_COLORS[:low_insufficient_inputs]).to eq("ffa500")
      expect(Resource::STATUS_COLORS[:high_insufficient_inputs]).to eq("b35900")
      expect(Resource::STATUS_COLORS[:stand_by]).to eq("00008b")
      expect(Resource::STATUS_COLORS[:low_manufacture]).to eq("00ff00")
      expect(Resource::STATUS_COLORS[:high_manufacture]).to eq("006400")
    end

    it "#high_manufacture! switches on and sets dark green" do
      resource.high_manufacture!
      expect(FakeTimberborn.levers["P:logs:M"]["state"]).to be true
      expect(FakeTimberborn.levers["P:logs:S"]["color"]).to eq("006400")
    end

    it "#low_manufacture! switches on and sets light green" do
      resource.low_manufacture!
      expect(FakeTimberborn.levers["P:logs:M"]["state"]).to be true
      expect(FakeTimberborn.levers["P:logs:S"]["color"]).to eq("00ff00")
    end

    it "#error! switches off and sets red" do
      FakeTimberborn.levers["P:logs:M"]["state"] = true
      resource.error!
      expect(FakeTimberborn.levers["P:logs:M"]["state"]).to be false
      expect(FakeTimberborn.levers["P:logs:S"]["color"]).to eq("ff0000")
    end

    it "#low_insufficient_inputs! switches off and sets light orange" do
      FakeTimberborn.levers["P:logs:M"]["state"] = true
      resource.low_insufficient_inputs!
      expect(FakeTimberborn.levers["P:logs:M"]["state"]).to be false
      expect(FakeTimberborn.levers["P:logs:S"]["color"]).to eq("ffa500")
    end

    it "#high_insufficient_inputs! switches off and sets dark orange" do
      FakeTimberborn.levers["P:logs:M"]["state"] = true
      resource.high_insufficient_inputs!
      expect(FakeTimberborn.levers["P:logs:M"]["state"]).to be false
      expect(FakeTimberborn.levers["P:logs:S"]["color"]).to eq("b35900")
    end

    it "#stand_by! switches off and sets blue" do
      FakeTimberborn.levers["P:logs:M"]["state"] = true
      resource.stand_by!
      expect(FakeTimberborn.levers["P:logs:M"]["state"]).to be false
      expect(FakeTimberborn.levers["P:logs:S"]["color"]).to eq("00008b")
    end
  end

  describe "#update_status!" do
    it "applies high_manufacture! when logs above low and not high" do
      FakeTimberborn.adapters["P:logs:H"]["state"] = false
      FakeTimberborn.adapters["P:logs:L"]["state"] = true
      resource.update_status!
      expect(FakeTimberborn.levers["P:logs:M"]["state"]).to be true
      expect(FakeTimberborn.levers["P:logs:S"]["color"]).to eq("006400")
    end

    it "applies low_manufacture! when logs below low setpoint" do
      FakeTimberborn.adapters["P:logs:H"]["state"] = false
      FakeTimberborn.adapters["P:logs:L"]["state"] = false
      resource.update_status!
      expect(FakeTimberborn.levers["P:logs:M"]["state"]).to be true
      expect(FakeTimberborn.levers["P:logs:S"]["color"]).to eq("00ff00")
    end

    it "applies stand_by! when high" do
      FakeTimberborn.adapters["P:logs:H"]["state"] = true
      resource.update_status!
      expect(FakeTimberborn.levers["P:logs:M"]["state"]).to be false
      expect(FakeTimberborn.levers["P:logs:S"]["color"]).to eq("00008b")
    end

    it "applies high_insufficient_inputs! for planks when logs not at low but planks at low" do
      FakeTimberborn.adapters["P:planks:H"]["state"] = false
      FakeTimberborn.adapters["P:planks:L"]["state"] = true
      FakeTimberborn.adapters["P:logs:L"]["state"] = false
      manager.planks.update_status!
      expect(FakeTimberborn.levers["P:planks:M"]["state"]).to be false
      expect(FakeTimberborn.levers["P:planks:S"]["color"]).to eq("b35900")
    end
  end


  describe "#dependencies" do
    it "returns an empty array for logs (no dependencies)" do
      expect(manager.logs.dependencies).to eq([])
    end

    it "returns logs as a dependency of planks" do
      expect(manager.planks.dependencies).to eq([manager.logs])
    end
  end

  describe "#determine_status" do
    it "returns :stand_by when high is true" do
      FakeTimberborn.adapters["P:logs:H"]["state"] = true
      expect(resource.determine_status).to eq(:stand_by)
    end

    it "returns :high_manufacture when not high, above low, no dependencies" do
      FakeTimberborn.adapters["P:logs:H"]["state"] = false
      FakeTimberborn.adapters["P:logs:L"]["state"] = true
      expect(resource.determine_status).to eq(:high_manufacture)
    end

    it "returns :low_manufacture when not high, below low, no dependencies" do
      FakeTimberborn.adapters["P:logs:H"]["state"] = false
      FakeTimberborn.adapters["P:logs:L"]["state"] = false
      expect(resource.determine_status).to eq(:low_manufacture)
    end

    it "returns :high_insufficient_inputs for planks when deps not at low and own low is true" do
      FakeTimberborn.adapters["P:planks:H"]["state"] = false
      FakeTimberborn.adapters["P:planks:L"]["state"] = true
      FakeTimberborn.adapters["P:logs:L"]["state"] = false
      expect(manager.planks.determine_status).to eq(:high_insufficient_inputs)
    end

    it "returns :low_insufficient_inputs for planks when deps not at low and own low is false" do
      FakeTimberborn.adapters["P:planks:H"]["state"] = false
      FakeTimberborn.adapters["P:planks:L"]["state"] = false
      FakeTimberborn.adapters["P:logs:L"]["state"] = false
      expect(manager.planks.determine_status).to eq(:low_insufficient_inputs)
    end

    it "returns :high_manufacture for planks when logs is at low" do
      FakeTimberborn.adapters["P:planks:H"]["state"] = false
      FakeTimberborn.adapters["P:planks:L"]["state"] = true
      FakeTimberborn.adapters["P:logs:L"]["state"] = true
      expect(manager.planks.determine_status).to eq(:high_manufacture)
    end
  end
end
