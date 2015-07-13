require 'rubygems'
#require 'byebug'
require 'pry'

$LOAD_PATH.unshift File.expand_path('../../lib',__FILE__)

require 'cellunats'

session = NATS::Session.new

session.async.run
#puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++"
session.subscribe subject: "foo", sid: 2

#binding.pry

loop { true }