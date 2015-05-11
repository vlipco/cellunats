require 'rubygems'
require 'bundler/setup'

Bundler.require

$logger = Logger.new STDOUT
$logger.level = Logger::INFO

$LOAD_PATH.unshift './lib/cellunats/protocol/session'

require 'session'

chan = 'loop' #SecureRandom.base64

s = CelluNATS::Protocol::Session.new
s.send_subscribe subject: chan, queue: chan, sid: 2
s.async.run

r = CelluNATS::Protocol::Session.new
r.send_subscribe subject: chan, queue: chan, sid: 2
r.async.run

t = CelluNATS::Protocol::Session.new
t.send_subscribe subject: chan, queue: chan, sid: 2
t.async.run

loop { true }
#binding.pry
