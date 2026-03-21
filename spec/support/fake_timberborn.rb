require "sinatra/base"
require "json"

class FakeTimberborn < Sinatra::Base
  set :protection, except: :host_routing
  DEFAULT_LEVERS = {
    "P:logs:S"         => { "name" => "P:logs:S",         "state" => false, "springReturn" => false },
    "P:logs:M"         => { "name" => "P:logs:M",         "state" => false, "springReturn" => false },
    "P:planks:S"       => { "name" => "P:planks:S",       "state" => false, "springReturn" => false },
    "P:planks:M"       => { "name" => "P:planks:M",       "state" => false, "springReturn" => false },
    "P:gears:S"        => { "name" => "P:gears:S",        "state" => false, "springReturn" => false },
    "P:gears:M"        => { "name" => "P:gears:M",        "state" => false, "springReturn" => false },
    "P:scrap_metals:S" => { "name" => "P:scrap_metals:S", "state" => false, "springReturn" => false },
    "P:scrap_metals:M" => { "name" => "P:scrap_metals:M", "state" => false, "springReturn" => false },
    "P:metal_parts:S"  => { "name" => "P:metal_parts:S",  "state" => false, "springReturn" => false },
    "P:metal_parts:M"  => { "name" => "P:metal_parts:M",  "state" => false, "springReturn" => false },
    "P:kohlrabi:S"     => { "name" => "P:kohlrabi:S",     "state" => false, "springReturn" => false },
    "P:kohlrabi:M"       => { "name" => "P:kohlrabi:M",       "state" => false, "springReturn" => false },
    "P:metal_blocks:S"   => { "name" => "P:metal_blocks:S",   "state" => false, "springReturn" => false },
    "P:metal_blocks:M"   => { "name" => "P:metal_blocks:M",   "state" => false, "springReturn" => false },
    "P:pine_resins:S"    => { "name" => "P:pine_resins:S",    "state" => false, "springReturn" => false },
    "P:pine_resins:M"    => { "name" => "P:pine_resins:M",    "state" => false, "springReturn" => false },
    "P:treated_planks:S" => { "name" => "P:treated_planks:S", "state" => false, "springReturn" => false },
    "P:treated_planks:M" => { "name" => "P:treated_planks:M", "state" => false, "springReturn" => false },
    "P:waters:S"         => { "name" => "P:waters:S",         "state" => false, "springReturn" => false },
    "P:waters:M"         => { "name" => "P:waters:M",         "state" => false, "springReturn" => false },
    "P:badwaters:S"      => { "name" => "P:badwaters:S",      "state" => false, "springReturn" => false },
    "P:badwaters:M"      => { "name" => "P:badwaters:M",      "state" => false, "springReturn" => false },
    "P:extracts:S"       => { "name" => "P:extracts:S",       "state" => false, "springReturn" => false },
    "P:extracts:M"       => { "name" => "P:extracts:M",       "state" => false, "springReturn" => false },
    "P:explosives:S"     => { "name" => "P:explosives:S",     "state" => false, "springReturn" => false },
    "P:explosives:M"     => { "name" => "P:explosives:M",     "state" => false, "springReturn" => false },
    "P:fireworks:S"      => { "name" => "P:fireworks:S",      "state" => false, "springReturn" => false },
    "P:fireworks:M"      => { "name" => "P:fireworks:M",      "state" => false, "springReturn" => false },
    "P:berries:S"        => { "name" => "P:berries:S",        "state" => false, "springReturn" => false },
    "P:berries:M"        => { "name" => "P:berries:M",        "state" => false, "springReturn" => false }
  }.freeze

  DEFAULT_ADAPTERS = {
    "P:logs:L"         => { "name" => "P:logs:L",         "state" => false },
    "P:logs:H"         => { "name" => "P:logs:H",         "state" => false },
    "P:planks:L"       => { "name" => "P:planks:L",       "state" => false },
    "P:planks:H"       => { "name" => "P:planks:H",       "state" => false },
    "P:gears:L"        => { "name" => "P:gears:L",        "state" => false },
    "P:gears:H"        => { "name" => "P:gears:H",        "state" => false },
    "P:scrap_metals:L" => { "name" => "P:scrap_metals:L", "state" => false },
    "P:scrap_metals:H" => { "name" => "P:scrap_metals:H", "state" => false },
    "P:metal_parts:L"  => { "name" => "P:metal_parts:L",  "state" => false },
    "P:metal_parts:H"  => { "name" => "P:metal_parts:H",  "state" => false },
    "P:kohlrabi:L"     => { "name" => "P:kohlrabi:L",     "state" => false },
    "P:kohlrabi:H"       => { "name" => "P:kohlrabi:H",       "state" => false },
    "P:metal_blocks:L"   => { "name" => "P:metal_blocks:L",   "state" => false },
    "P:metal_blocks:H"   => { "name" => "P:metal_blocks:H",   "state" => false },
    "P:pine_resins:L"    => { "name" => "P:pine_resins:L",    "state" => false },
    "P:pine_resins:H"    => { "name" => "P:pine_resins:H",    "state" => false },
    "P:treated_planks:L" => { "name" => "P:treated_planks:L", "state" => false },
    "P:treated_planks:H" => { "name" => "P:treated_planks:H", "state" => false },
    "P:waters:L"         => { "name" => "P:waters:L",         "state" => false },
    "P:waters:H"         => { "name" => "P:waters:H",         "state" => false },
    "P:badwaters:L"      => { "name" => "P:badwaters:L",      "state" => false },
    "P:badwaters:H"      => { "name" => "P:badwaters:H",      "state" => false },
    "P:extracts:L"       => { "name" => "P:extracts:L",       "state" => false },
    "P:extracts:H"       => { "name" => "P:extracts:H",       "state" => false },
    "P:explosives:L"     => { "name" => "P:explosives:L",     "state" => false },
    "P:explosives:H"     => { "name" => "P:explosives:H",     "state" => false },
    "P:fireworks:L"      => { "name" => "P:fireworks:L",      "state" => false },
    "P:fireworks:H"      => { "name" => "P:fireworks:H",      "state" => false },
    "P:berries:L"        => { "name" => "P:berries:L",        "state" => false },
    "P:berries:H"        => { "name" => "P:berries:H",        "state" => false }
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
