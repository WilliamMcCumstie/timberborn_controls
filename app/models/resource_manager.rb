class ResourceManager
  include TSort

  CONFIG_PATH = File.join(__dir__, "../../config/resources.yml")

  attr_reader :config, :prefix, :remote

  def initialize(prefix: Config::RESOURCE_PREFIX, remote: Config.adapter)
    @prefix = prefix
    @remote = remote
    @config = YAML.load_file(CONFIG_PATH)
  end

  def logs
    @logs ||= Resource.new("logs", manager: self)
  end

  def planks
    @planks ||= Resource.new("planks", manager: self)
  end

  def all_resources
    [logs, planks]
  end

  def update_status!
    LOGGER.info("#{self.class}: update_status!")
    tsort.each(&:update_status!)
  end

  private

  def tsort_each_node(&block)
    all_resources.each(&block)
  end

  def tsort_each_child(resource, &block)
    resource.dependencies.each(&block)
  end
end
