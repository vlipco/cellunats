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
    loop do
      c.send_command :publish, subject: 'loop', message: Time.now.to_f.to_s
      sleep 0.25
    end
loop { true }
#require 'pry'
#binding.pry

