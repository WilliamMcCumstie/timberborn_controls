require "spec_helper"

RSpec.describe ResourceManager do
  let(:manager) { ResourceManager.new }

  describe "#logs" do
    it "returns a Resource for logs" do
      expect(manager.logs).to be_a(Resource)
      expect(manager.logs.name).to eq("logs")
    end

    it "memoizes the resource" do
      expect(manager.logs).to be(manager.logs)
    end
  end

  describe "#planks" do
    it "returns a Resource for planks" do
      expect(manager.planks).to be_a(Resource)
      expect(manager.planks.name).to eq("planks")
    end

    it "memoizes the resource" do
      expect(manager.planks).to be(manager.planks)
    end
  end

  describe "#update_status!" do
    it "updates all resources in dependency order (logs before planks)" do
      FakeTimberborn.adapters["P:logs:H"]["state"] = false
      FakeTimberborn.adapters["P:logs:L"]["state"] = true
      FakeTimberborn.adapters["P:planks:H"]["state"] = false
      order = []
      allow(manager.logs).to receive(:update_status!).and_wrap_original { |m| order << :logs; m.call }
      allow(manager.planks).to receive(:update_status!).and_wrap_original { |m| order << :planks; m.call }
      manager.update_status!
      expect(order).to eq([:logs, :planks])
    end
  end


  describe "prefix" do
    it "defaults to Config::RESOURCE_PREFIX" do
      expect(manager.logs.prefix).to eq(Config::RESOURCE_PREFIX)
    end

    it "passes a custom prefix down to resources" do
      m = ResourceManager.new(prefix: "X")
      expect(m.logs.prefix).to eq("X")
      expect(m.planks.prefix).to eq("X")
    end
  end
end
