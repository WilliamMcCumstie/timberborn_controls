require_relative "../boot"

manager = ResourceManager.new

LOGGER.info("Starting main loop")

loop do
  LOADER.reload
  manager = ResourceManager.new
  manager.update_status!
  LOGGER.info("Sleeping for 5s...")
  sleep 5
end
