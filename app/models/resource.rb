class Resource
  STATUS_COLORS = {
    error:               "ff0000",
    insufficient_inputs: "ffa500",
    stand_by:            "0000ff",
    manufacture:         "00ff00"
  }.freeze

  attr_reader :name, :prefix

  def initialize(name, prefix: Config::RESOURCE_PREFIX, remote: Config.adapter)
    @name = name
    @prefix = prefix
    @remote = remote
  end

  def low
    @remote.adapter(resource_name("L"))["state"]
  end

  def high
    @remote.adapter(resource_name("H"))["state"]
  end

  def switch_on
    @remote.switch_on(resource_name("M"))
  end

  def switch_off
    @remote.switch_off(resource_name("M"))
  end

  def set_color(hex)
    @remote.switch_on(resource_name("S"))
    @remote.set_color(resource_name("S"), hex)
  end

  STATUS_COLORS.each_key do |status|
    define_method(:"#{status}!") do
      status == :manufacture ? switch_on : switch_off
      set_color(STATUS_COLORS[status])
    end
  end

  private

  def resource_name(port)
    "#{@prefix}:#{@name}:#{port}"
  end
end
