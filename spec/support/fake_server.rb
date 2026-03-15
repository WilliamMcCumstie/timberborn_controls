require "rackup/handler/webrick"
require "webrick"
require "net/http"
require "timeout"

module FakeServer
  PORT = 9292
  URL  = "http://localhost:#{PORT}"

  def self.start
    @thread = Thread.new do
      Rackup::Handler::WEBrick.run(
        FakeTimberborn.new,
        Port: PORT,
        Logger: WEBrick::Log.new(File::NULL),
        AccessLog: []
      )
    end
    wait_for_boot
  end

  def self.wait_for_boot
    Timeout.timeout(5) do
      loop do
        Net::HTTP.get(URI("#{URL}/api/levers"))
        break
      rescue Errno::ECONNREFUSED
        sleep 0.05
      end
    end
  end
end
