require "spec_helper"

RSpec.describe RemoteAdapter do
  let(:adapter) { Config.adapter }

  describe "#levers" do
    it "returns a list of levers" do
      result = adapter.levers
      expect(result).to be_an(Array)
      expect(result.first["name"]).to eq("P:logs:S")
    end
  end

  describe "#lever" do
    it "returns a single lever" do
      result = adapter.lever("P:logs:S")
      expect(result["name"]).to eq("P:logs:S")
    end
  end

  describe "#switch_on" do
    it "switches a lever on and returns true" do
      expect(adapter.switch_on("P:logs:S")).to be true
    end
  end

  describe "#switch_off" do
    it "switches a lever off and returns true" do
      expect(adapter.switch_off("P:logs:S")).to be true
    end
  end

  describe "#set_color" do
    it "sets a lever colour and returns true" do
      expect(adapter.set_color("P:logs:S", "ff0000")).to be true
    end
  end

  describe "#adapters" do
    it "returns a list of adapters" do
      result = adapter.adapters
      expect(result).to be_an(Array)
      expect(result.first["name"]).to eq("P:logs:L")
    end
  end

  describe "#adapter" do
    it "returns a single adapter" do
      result = adapter.adapter("P:logs:L")
      expect(result["name"]).to eq("P:logs:L")
    end
  end
end
