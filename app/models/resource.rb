class Resource
  STATUS_COLORS = {
    error:               "ff0000",
    insufficient_inputs: "ffa500",
    stand_by:            "0000ff",
    manufacture:         "00ff00"
  }.freeze

  attr_reader :name

  def initialize(name, manager:)
    @name = name
    @manager = manager
  end

  def prefix = @manager.prefix
  def remote  = @manager.remote

  def low
    remote.adapter(resource_name("L"))["state"]
  end

  def high
    remote.adapter(resource_name("H"))["state"]
  end

  def switch_on
    LOGGER.info("#{self.class}(#{@name}): switch_on")
    remote.switch_on(resource_name("M"))
  end

  def switch_off
    LOGGER.info("#{self.class}(#{@name}): switch_off")
    remote.switch_off(resource_name("M"))
  end

  def set_color(hex)
    LOGGER.info("#{self.class}(#{@name}): set_color #{hex}")
    remote.switch_on(resource_name("S"))
    remote.set_color(resource_name("S"), hex)
  end

  def dependencies
    dep_names = @manager.config.dig("dependencies", @name) || []
    dep_names.map { |dep| @manager.public_send(dep) }
  end

  def determine_status
    status = begin
      return :stand_by if high
      return :insufficient_inputs if dependencies.any? { |dep| !dep.low }
      :manufacture
    rescue
      :error
    end
    LOGGER.info("#{self.class}(#{@name}): determine_status => #{status}")
    status
  end

  def update_status!
    LOGGER.info("#{self.class}(#{@name}): update_status!")
    public_send(:"#{determine_status}!")
  end

  STATUS_COLORS.each_key do |status|
    define_method(:"#{status}!") do
      status == :manufacture ? switch_on : switch_off
      set_color(STATUS_COLORS[status])
    end
  end

  private

  def resource_name(port)
    "#{@manager.prefix}:#{@name}:#{port}"
  end
end
