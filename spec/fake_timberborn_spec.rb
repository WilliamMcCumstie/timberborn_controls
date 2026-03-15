require "spec_helper"

RSpec.describe FakeTimberborn do
  describe "GET /api/levers" do
    it "returns all levers" do
      get "/api/levers"
      expect(last_response.status).to eq(200)
      body = JSON.parse(last_response.body)
      expect(body).to be_an(Array)
      expect(body.first["name"]).to eq("HTTP Lever 1")
    end
  end

  describe "GET /api/levers/:name" do
    it "returns a single lever" do
      get "/api/levers/HTTP%20Lever%201"
      expect(last_response.status).to eq(200)
      body = JSON.parse(last_response.body)
      expect(body["name"]).to eq("HTTP Lever 1")
    end

    it "returns 404 for unknown lever" do
      get "/api/levers/Unknown"
      expect(last_response.status).to eq(404)
    end
  end

  describe "POST /api/switch-on/:name" do
    it "switches the lever on" do
      post "/api/switch-on/HTTP%20Lever%201"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("OK")
      expect(FakeTimberborn.levers["HTTP Lever 1"]["state"]).to be true
    end

    it "returns 404 for unknown lever" do
      post "/api/switch-on/Unknown"
      expect(last_response.status).to eq(404)
    end
  end

  describe "POST /api/switch-off/:name" do
    it "switches the lever off" do
      FakeTimberborn.levers["HTTP Lever 1"]["state"] = true
      post "/api/switch-off/HTTP%20Lever%201"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("OK")
      expect(FakeTimberborn.levers["HTTP Lever 1"]["state"]).to be false
    end

    it "returns 404 for unknown lever" do
      post "/api/switch-off/Unknown"
      expect(last_response.status).to eq(404)
    end
  end

  describe "POST /api/color/:name/:hex" do
    it "sets the lever colour" do
      post "/api/color/HTTP%20Lever%201/ff0000"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("OK")
      expect(FakeTimberborn.levers["HTTP Lever 1"]["color"]).to eq("ff0000")
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
      expect(body.first["name"]).to eq("HTTP Adapter 1")
    end
  end

  describe "GET /api/adapters/:name" do
    it "returns a single adapter" do
      get "/api/adapters/HTTP%20Adapter%201"
      expect(last_response.status).to eq(200)
      body = JSON.parse(last_response.body)
      expect(body["name"]).to eq("HTTP Adapter 1")
    end

    it "returns 404 for unknown adapter" do
      get "/api/adapters/Unknown"
      expect(last_response.status).to eq(404)
    end
  end
end
