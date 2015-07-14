require 'rubygems'
require 'byebug'
require 'pry'

$LOAD_PATH.unshift File.expand_path('../../lib',__FILE__)

require 'cellunats'

$logger = Logger.new STDOUT
$logger.level = Logger::INFO
$logger.formatter = proc do |severity, datetime, progname, msg|
   "#{severity}: #{msg}\n"
end

Celluloid.logger = $logger

require 'celluloid/autostart'
session = NATS::Session.new

Celluloid::Actor[:session] = session

session.async.run

5.times do
  session.async.latency_echo
end

loop { true }