require 'rubygems'
require 'bundler/setup'

$LOAD_PATH.unshift './lib/cellunats/protocol'
require 'protocol'
require 'celluloid/autostart'
require 'client'



class Handler
  include Celluloid
  include Celluloid::Notifications

  attr_accessor :handlers

  # binds passed handlers to this object
  execute_block_on_receiver :subscribe_to

  def initialize
    subscribe 'payload', :handle_payload
    @handlers = {}
    @client = CelluNATS::Protocol::Client.new
    @client.async.run
  end

  def handle_payload(topic,event)
    puts event
    sub = event[:sub].to_s # unified access
    puts "Porcessing pauload of #{sub}"
    handler = @handlers[sub]
    puts handler
    handler.call event[:payload]
    puts "DONE"
  end

  def subscribe_to(topic, &block)
    sid = @handlers.keys.length + 1
    puts "Saving handler for #{topic}"
    @handlers[topic.to_s] = block
    @client.send_command :subscribe, subject: topic, sid: sid
  end

  def request(topic,message='')
    condition = Celluloid::Condition.new
    reply_channel = condition.__id__
    subscribe_to reply_channel do |response|
      condition.signal response
    end
    @client.send_command :publish, subject: topic, msg: message, reply: reply_channel
    return condition.wait
  end

end

h = Handler.new

h.subscribe_to 'foo' do |msg|
  #raise "aloha?"
  puts "!!! #{msg}"
end

puts "WAITING!"
c = h.request 'help'
puts "RESULT= #{c}"

require 'pry'
binding.pry

#loop { true }

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