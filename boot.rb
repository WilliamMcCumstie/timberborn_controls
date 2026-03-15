require "zeitwerk"
require "faraday"
require "logger"
require "yaml"
require "tsort"

require_relative "config"
require_relative "app/logger"

loader = Zeitwerk::Loader.new
loader.push_dir(File.join(__dir__, "app"))
loader.collapse(File.join(__dir__, "app/models"))
loader.setup
