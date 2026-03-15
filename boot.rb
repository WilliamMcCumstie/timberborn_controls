require "zeitwerk"
require "faraday"

require_relative "config"

loader = Zeitwerk::Loader.new
loader.push_dir(File.join(__dir__, "app"))
loader.collapse(File.join(__dir__, "app/models"))
loader.setup
