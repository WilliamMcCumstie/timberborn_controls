require "sinatra/base"
require "json"

class FakeTimberborn < Sinatra::Base
  set :protection, except: :host_routing
  DEFAULT_LEVERS = {
    "P:log:S" => { "name" => "P:log:S", "state" => false, "springReturn" => false },
    "P:log:M" => { "name" => "P:log:M", "state" => false, "springReturn" => false }
  }.freeze

  DEFAULT_ADAPTERS = {
    "P:log:L" => { "name" => "P:log:L", "state" => false },
    "P:log:H" => { "name" => "P:log:H", "state" => false }
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
