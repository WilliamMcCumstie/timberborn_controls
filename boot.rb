require "zeitwerk"
require "faraday"

require_relative "config"

loader = Zeitwerk::Loader.new
loader.push_dir(File.join(__dir__, "app"))
loader.setup
