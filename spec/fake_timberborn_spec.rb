require "spec_helper"

RSpec.describe FakeTimberborn do
  describe "GET /api/levers" do
    it "returns all levers" do
      get "/api/levers"
      expect(last_response.status).to eq(200)
      body = JSON.parse(last_response.body)
      expect(body).to be_an(Array)
      expect(body.first["name"]).to eq("P:log:S")
    end
  end

  describe "GET /api/levers/:name" do
    it "returns a single lever" do
      get "/api/levers/P%3Alog%3AS"
      expect(last_response.status).to eq(200)
      body = JSON.parse(last_response.body)
      expect(body["name"]).to eq("P:log:S")
    end

    it "returns 404 for unknown lever" do
      get "/api/levers/Unknown"
      expect(last_response.status).to eq(404)
    end
  end

  describe "POST /api/switch-on/:name" do
    it "switches the lever on" do
      post "/api/switch-on/P%3Alog%3AS"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("OK")
      expect(FakeTimberborn.levers["P:log:S"]["state"]).to be true
    end

    it "returns 404 for unknown lever" do
      post "/api/switch-on/Unknown"
      expect(last_response.status).to eq(404)
    end
  end

  describe "POST /api/switch-off/:name" do
    it "switches the lever off" do
      FakeTimberborn.levers["P:log:S"]["state"] = true
      post "/api/switch-off/P%3Alog%3AS"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("OK")
      expect(FakeTimberborn.levers["P:log:S"]["state"]).to be false
    end

    it "returns 404 for unknown lever" do
      post "/api/switch-off/Unknown"
      expect(last_response.status).to eq(404)
    end
  end

  describe "POST /api/color/:name/:hex" do
    it "sets the lever colour" do
      post "/api/color/P%3Alog%3AS/ff0000"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("OK")
      expect(FakeTimberborn.levers["P:log:S"]["color"]).to eq("ff0000")
    end

    it "returns 404 for unknown lever" do
      post "/api/color/Unknown/ff0000"
      expect(last_response.status).to eq(404)
    end
  end

  describe "GET /api/adapters" do
    it "returns all adapters" do
      get "/api/adapters"
      expect(last_response.status).to eq(200)
      body = JSON.parse(last_response.body)
      expect(body).to be_an(Array)
      expect(body.first["name"]).to eq("P:log:L")
    end
  end

  describe "GET /api/adapters/:name" do
    it "returns a single adapter" do
      get "/api/adapters/P%3Alog%3AL"
      expect(last_response.status).to eq(200)
      body = JSON.parse(last_response.body)
      expect(body["name"]).to eq("P:log:L")
    end

    it "returns 404 for unknown adapter" do
      get "/api/adapters/Unknown"
      expect(last_response.status).to eq(404)
    end
  end
end
