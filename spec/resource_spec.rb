require "spec_helper"

RSpec.describe Resource do
  let(:resource) { Resource.new("log") }

  describe "#name and #prefix" do
    it "exposes the building name" do
      expect(resource.name).to eq("log")
    end

    it "defaults prefix to Config::RESOURCE_PREFIX" do
      expect(resource.prefix).to eq(Config::RESOURCE_PREFIX)
    end

    it "accepts a custom prefix" do
      r = Resource.new("log", prefix: "X")
      expect(r.prefix).to eq("X")
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
      FakeTimberborn.levers["P:log:S"]["state"] = false
      resource.set_color("ff0000")
      expect(FakeTimberborn.levers["P:log:S"]["state"]).to be true
      expect(FakeTimberborn.levers["P:log:S"]["color"]).to eq("ff0000")
    end
  end

  describe "status color helpers" do
    it "defines STATUS_COLORS" do
      expect(Resource::STATUS_COLORS[:error]).to eq("ff0000")
      expect(Resource::STATUS_COLORS[:insufficient_inputs]).to eq("ffa500")
      expect(Resource::STATUS_COLORS[:stand_by]).to eq("0000ff")
      expect(Resource::STATUS_COLORS[:manufacture]).to eq("00ff00")
    end

    it "#manufacture! switches on and sets green" do
      resource.manufacture!
      expect(FakeTimberborn.levers["P:log:M"]["state"]).to be true
      expect(FakeTimberborn.levers["P:log:S"]["color"]).to eq("00ff00")
    end

    it "#error! switches off and sets red" do
      FakeTimberborn.levers["P:log:M"]["state"] = true
      resource.error!
      expect(FakeTimberborn.levers["P:log:M"]["state"]).to be false
      expect(FakeTimberborn.levers["P:log:S"]["color"]).to eq("ff0000")
    end

    it "#insufficient_inputs! switches off and sets orange" do
      FakeTimberborn.levers["P:log:M"]["state"] = true
      resource.insufficient_inputs!
      expect(FakeTimberborn.levers["P:log:M"]["state"]).to be false
      expect(FakeTimberborn.levers["P:log:S"]["color"]).to eq("ffa500")
    end

    it "#stand_by! switches off and sets blue" do
      FakeTimberborn.levers["P:log:M"]["state"] = true
      resource.stand_by!
      expect(FakeTimberborn.levers["P:log:M"]["state"]).to be false
      expect(FakeTimberborn.levers["P:log:S"]["color"]).to eq("0000ff")
    end
  end
end
