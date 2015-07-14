require 'rubygems'
require 'byebug'
require 'pry'

$LOAD_PATH.unshift File.expand_path('../lib',__FILE__)

require 'cellunats/driver'


require 'thread'

queue = Queue.new

queue << %Q[INFO {"server_id":"131aae601493e3b129aeb6b1435263be","version":"0.6.1.beta","host":"0.0.0.0","port":4222,"auth_required":false,"ssl_required":false,"max_payload":1048576}\r\n]
queue << "MSG foo 2 6\r\n"
queue << "aloha!\r\n"
queue << "PING\r\n"
queue << "PONG\r\n"

class Handler
  def write(buffer)
    puts "==> #{buffer}"
  end
end

driver = NATS::Protocol::Driver.new Handler.new

until queue.empty?
  driver.parse queue.pop
  driver.connect if driver.server_info && driver.disconnected
end

driver.request "echo", Time.now.to_f

#binding.pry


