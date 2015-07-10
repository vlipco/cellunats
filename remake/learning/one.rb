require 'rubygems'
require 'statemachine'
require 'pry'
require 'byebug'
#require 'celluloid/io'
require 'socket'

$LOAD_PATH.unshift '../lib/'

require 'context.rb'
require 'statemachine.rb'
require 'session.rb'

session = NATS::Session.new

session.connect

#binding.pry