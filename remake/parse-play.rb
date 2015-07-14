require 'rubygems'
require 'byebug'
require 'pry'

$LOAD_PATH.unshift File.expand_path('../lib',__FILE__)

require 'cellunats/driver'

session = %Q(INFO {"server_id":"131aae601493e3b129aeb6b1435263be","version":"0.6.1.beta","host":"0.0.0.0","port":4222,"auth_required":false,"ssl_required":false,"max_payload":1048576}\r
MSG foo 2 6\r
aloha!\r
PONG\r
PING\r\n)

driver = NATS::Protocol::Driver.new

driver.parse session

#binding.pry


