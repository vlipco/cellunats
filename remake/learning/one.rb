require 'rubygems'
#require 'byebug'
require 'pry'

$LOAD_PATH.unshift File.expand_path('../../lib',__FILE__)

#require 'celluloid'
#require 'celluloid/autostart'

require 'cellunats'

$logger = Logger.new STDOUT
$logger.level = Logger::INFO
$logger.formatter = proc do |severity, datetime, progname, msg|
   "#{severity}: #{msg}\n"
end

Celluloid.logger = $logger

#binding.pry
session = NATS::Session.new

sleep 0.5

session.driver.subscribe 'foo'
#session.driver.subscribe 'loop2'
#session.driver.subscribe 'loop3'

#def do_echo
#  session.driver.request "echo", Time.now.to_f
#end

loop { true }

diff = (Time.now.to_f*1000).to_i - @msg.body.to_i