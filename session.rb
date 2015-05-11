require 'rubygems'
require 'bundler/setup'

Bundler.require

$logger = Logger.new STDOUT
$logger.level = Logger::INFO

$LOAD_PATH.unshift './lib/cellunats/protocol/session'

require 'session'

chan = 'loop' #SecureRandom.base64

s = CelluNATS::Protocol::Session.new
#bg = Thread.new do 
  $logger.debug "=== STARTING SUB"
  s.send_subscribe subject: chan, sid: 2
  $logger.debug "=== SUB READY?"
  s.session.connect 
  loop do
    s.read_command
  end
#end
#s.info.symbolize!
puts "Post to #{chan}"
binding.pry

