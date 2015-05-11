require 'rubygems'
require 'bundler/setup'

$LOAD_PATH.unshift './lib/cellunats/protocol'

require 'protocol'
require 'celluloid/autostart'
require 'client'

#class CelluNATS::Protocol::Client
#  def loop
#    send_command :subscribe, subject: 'loop', sid: 2
#    loop do
#      send_command :pub, subject: 'loop', message: Time.now.to_f.to_s
#    end
#  end
#end

c = CelluNATS::Protocol::Client.new
c.async.run
#c.loop

c.send_command :subscribe, subject: 'loop', sid: 2

1000.times do
  print ">"
  c.send_command :publish, subject: 'loop', message: Time.now.to_node_timestamp
end

puts "\n----\n"

loop { true }

require 'pry'
binding.pry
#puts "#{c.average_delay}ms (#{c.delays.size}req.)"
