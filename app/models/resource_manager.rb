class ResourceManager
  include TSort

  CONFIG_PATH = File.join(__dir__, "../../config/resources.yml")

  attr_reader :config, :prefix, :remote

  def initialize(prefix: Config::RESOURCE_PREFIX, remote: Config.adapter)
    @prefix = prefix
    @remote = remote
    @config = YAML.load_file(CONFIG_PATH)
    modes = @config.fetch("scrap_metals_modes")
    mode  = Config.scrap_metals_mode
    raise "Invalid SCRAP_METALS_MODE: #{mode.inspect}. Valid: #{modes.keys.join(', ')}" unless modes.key?(mode)
    scrap_deps = modes[mode]
    @config["dependencies"]["scrap_metals"] = scrap_deps unless scrap_deps.empty?
  end

  def logs
    @logs ||= Resource.new("logs", manager: self)
  end

  def planks
    @planks ||= Resource.new("planks", manager: self)
  end

  def gears
    @gears ||= Resource.new("gears", manager: self)
  end

  def scrap_metals
    @scrap_metals ||= Resource.new("scrap_metals", manager: self)
  end

  def metal_parts
    @metal_parts ||= Resource.new("metal_parts", manager: self)
  end

  def kohlrabi
    @kohlrabi ||= Resource.new("kohlrabi", manager: self)
  end

  def pine_resins
    @pine_resins ||= Resource.new("pine_resins", manager: self)
  end

  def treated_planks
    @treated_planks ||= Resource.new("treated_planks", manager: self)
  end

  def extracts
    @extracts ||= Resource.new("extracts", manager: self)
  end

  def explosives
    @explosives ||= Resource.new("explosives", manager: self)
  end

  def fireworks
    @fireworks ||= Resource.new("fireworks", manager: self)
  end

  def waters
    @waters ||= Resource.new("waters", manager: self)
  end

  def badwaters
    @badwaters ||= Resource.new("badwaters", manager: self)
  end

  def metal_blocks
    @metal_blocks ||= Resource.new("metal_blocks", manager: self)
  end

  def all_resources
    [logs, planks, gears, scrap_metals, metal_parts, kohlrabi, metal_blocks, pine_resins, treated_planks, waters, badwaters, extracts, explosives, fireworks]
  end

  def update_status!
    LOGGER.info("#{self.class}: update_status!")
    remote.initialize_status_levers!(prefix)
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
