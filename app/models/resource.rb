class Resource
  STATUS_COLORS = {
    error:                      "ff0000", # bright red — something went wrong
    low_insufficient_inputs:    "ffa500", # light orange — critically low stock AND inputs missing
    high_insufficient_inputs:   "b35900", # dark orange — has some stock but inputs still missing
    stand_by:                   "00008b", # dark blue — storage full, not manufacturing
    low_manufacture:            "00ff00", # light green — manufacturing but critically low stock
    high_manufacture:           "006400"  # dark green — manufacturing, stock above low setpoint
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
      if dependencies.any? { |dep| !dep.low }
        return low ? :high_insufficient_inputs : :low_insufficient_inputs
      end
      return :low_manufacture unless low
      :high_manufacture
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
      [:low_manufacture, :high_manufacture].include?(status) ? switch_on : switch_off
      set_color(STATUS_COLORS[status])
    end
  end

  private

  def resource_name(port)
    "#{@manager.prefix}:#{@name}:#{port}"
  end
end
