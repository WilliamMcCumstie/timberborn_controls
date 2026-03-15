class RemoteAdapter
  def initialize(base_url: Config::TIMBERBORN_URL)
    @conn = Faraday.new(url: base_url) do |f|
      f.response :raise_error
    end
  end

  # Levers

  def levers
    response = @conn.get("/api/levers")
    JSON.parse(response.body)
  end

  def lever(name)
    response = @conn.get("/api/levers/#{encode(name)}")
    JSON.parse(response.body)
  end

  def switch_on(name)
    @conn.post("/api/switch-on/#{encode(name)}")
    true
  end

  def switch_off(name)
    @conn.post("/api/switch-off/#{encode(name)}")
    true
  end

  def set_color(name, hex)
    @conn.post("/api/color/#{encode(name)}/#{hex}")
    true
  end

  def initialize_status_levers!(prefix)
    pattern = /\A#{Regexp.escape(prefix)}:[^:]+:S\z/
    levers
      .map { |l| l["name"] }
      .select { |name| name.match?(pattern) }
      .each do |name|
        switch_on(name)
        set_color(name, Resource::INITIALIZING_COLOR)
      end
  end

  # Adapters

  def adapters
    response = @conn.get("/api/adapters")
    JSON.parse(response.body)
  end

  def adapter(name)
    response = @conn.get("/api/adapters/#{encode(name)}")
    JSON.parse(response.body)
  end

  private

  def encode(name)
    URI.encode_uri_component(name)
  end
end
