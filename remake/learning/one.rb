require 'rubygems'
require 'byebug'
require 'pry'

$LOAD_PATH.unshift File.expand_path('../../lib',__FILE__)

require 'cellunats'

session = NATS::Session.new

session.run