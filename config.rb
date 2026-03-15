module Config
  TIMBERBORN_URL      = "http://localhost:8080"
  RESOURCE_PREFIX     = "P"

  def self.adapter
    @adapter ||= RemoteAdapter.new
  end

  def self.adapter=(adapter)
    @adapter = adapter
  end
end
