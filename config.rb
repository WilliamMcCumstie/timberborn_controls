module Config
  TIMBERBORN_URL  = "http://localhost:8080"
  RESOURCE_PREFIX = "P"

  def self.scrap_metals_mode
    ENV.fetch("SCRAP_METALS_MODE", "none")
  end

  def self.adapter
    @adapter ||= RemoteAdapter.new
  end

  def self.adapter=(adapter)
    @adapter = adapter
  end
end
