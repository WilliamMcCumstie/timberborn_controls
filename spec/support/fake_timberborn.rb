require "sinatra/base"
require "json"

class FakeTimberborn < Sinatra::Base
  set :protection, except: :host_routing
  DEFAULT_LEVERS = {
    "P:logs:S"   => { "name" => "P:logs:S",   "state" => false, "springReturn" => false },
    "P:logs:M"   => { "name" => "P:logs:M",   "state" => false, "springReturn" => false },
    "P:planks:S" => { "name" => "P:planks:S", "state" => false, "springReturn" => false },
    "P:planks:M" => { "name" => "P:planks:M", "state" => false, "springReturn" => false }
  }.freeze

  DEFAULT_ADAPTERS = {
    "P:logs:L"   => { "name" => "P:logs:L",   "state" => false },
    "P:logs:H"   => { "name" => "P:logs:H",   "state" => false },
    "P:planks:L" => { "name" => "P:planks:L", "state" => false },
    "P:planks:H" => { "name" => "P:planks:H", "state" => false }
  }.freeze

  def self.reset!
    @levers = DEFAULT_LEVERS.transform_values(&:dup)
    @adapters = DEFAULT_ADAPTERS.transform_values(&:dup)
  end

  def self.levers = (@levers ||= DEFAULT_LEVERS.transform_values(&:dup))
  def self.adapters = (@adapters ||= DEFAULT_ADAPTERS.transform_values(&:dup))

  get "/api/levers" do
    content_type :json
    self.class.levers.values.to_json
  end

  get "/api/levers/:name" do
    content_type :json
    lever = self.class.levers[params[:name]]
    halt 404, { error: "Not found" }.to_json unless lever
    lever.to_json
  end

  post "/api/switch-on/:name" do
    lever = self.class.levers[params[:name]]
    halt 404, { error: "Not found" }.to_json unless lever
    lever["state"] = true
    "OK"
  end

  post "/api/switch-off/:name" do
    lever = self.class.levers[params[:name]]
    halt 404, { error: "Not found" }.to_json unless lever
    lever["state"] = false
    "OK"
  end

  post "/api/color/:name/:hex" do
    lever = self.class.levers[params[:name]]
    halt 404, { error: "Not found" }.to_json unless lever
    lever["color"] = params[:hex]
    "OK"
  end

  get "/api/adapters" do
    content_type :json
    self.class.adapters.values.to_json
  end

  get "/api/adapters/:name" do
    content_type :json
    adapter = self.class.adapters[params[:name]]
    halt 404, { error: "Not found" }.to_json unless adapter
    adapter.to_json
  end
end
