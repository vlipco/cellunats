require 'rubygems'
require 'bundler/setup'

$LOAD_PATH.unshift './lib/cellunats/protocol'
require 'protocol'
require 'celluloid/autostart'
require 'client'

c = CelluNATS::Protocol::Client.new
c.async.run

c.send_command :subscribe, subject: 'foo', sid: 2

require 'pry'
binding.pry

#encoder = CelluNATS::Protocol::Encoder.new
#decoder = CelluNATS::Protocol::Decoder.new
#
#puts encoder.connect verbose: true, pedantic: false
#puts encoder.subscribe subject: 'foo', sid: 2
#puts encoder.publish subject: 'foo', msg: 'mundo!'
#puts encoder.ping
#
#puts "----"
#
#puts decoder.parse "MSG foo 2 6"
#
#puts decoder.parse "MSG help 2 _INBOX.ce49335bdb176fefe61bc4aaca 0"