require "zeitwerk"
require "faraday"
require "logger"
require "yaml"
require "tsort"
require "dotenv"

files = ENV["APP_ENV"] == "test" ? [".env"] : [".env.local", ".env"]
Dotenv.load(*files)

require_relative "config"
require_relative "app/logger"

LOADER = Zeitwerk::Loader.new
LOADER.push_dir(File.join(__dir__, "app"))
LOADER.collapse(File.join(__dir__, "app/models"))
LOADER.enable_reloading
LOADER.setup
