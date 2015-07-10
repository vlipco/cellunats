#require 'rubygems'
#require 'bundler/setup'

$LOAD_PATH.unshift './lib/cellunats/protocol'
require 'protocol'
#require 'celluloid/autostart'
require 'client'

client = CelluNATS::Protocol::Client.new
result = client.single_request 'help'
#puts "***"
puts result
#client.run
#client.send_command :subscribe, subject: 'foo', sid: 2
#client.worker.join
#c = client.request 'help'

#require 'pry'
#binding.pry