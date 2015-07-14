require 'celluloid'
require 'celluloid/autostart'

class Receiver

  include Celluloid
  include Celluloid::Notifications

  def initialize
    subscribe 'aloha', :new_message
    puts "..."
  end

  def new_message(topic,data)
    diff = Time.now.to_f - data.to_f
    puts "RCV #{diff*1000}"
  end
end

receiver = Receiver.new

5.times do
  Celluloid::Notifications.publish 'aloha', Time.now.to_f
end

loop { true }