require 'rubygems'
require 'bundler/setup'

$LOAD_PATH.unshift './lib/cellunats/protocol'

require 'protocol'
require 'celluloid/autostart'
require 'client'

c = CelluNATS::Protocol::Client.new

c.async.run

c.send_command :subscribe, subject: 'loop', sid: 2

1000.times do
  stamp = Time.now.to_f.to_s
  c.send_command :publish, subject: 'loop', message: stamp
end

c.terminate