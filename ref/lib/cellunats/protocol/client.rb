#require 'socket'
require 'celluloid/io'


module CelluNATS
  module Protocol
    class Client

      include Constants

      include Celluloid::IO

      include Celluloid::Notifications


      finalizer :shutdown

      attr_accessor :config, :socket, :encoder, :decoder

      def shutdown
        #puts "Closing socket"
        socket.close if socket
      end


      def initialize(opt={})
        #puts "*** Starting server!"
        @config = opt
        @expecting_payload = false
        @encoder = Encoder.new
        @decoder = Decoder.new
        @socket = TCPSocket.new '127.0.0.1', '4222'
      end

      def send_command(command, *args)
        ##puts "#{command}=#{args}"
        cmd = encoder.send command, *args
        socket.puts cmd
        #puts cmd
      end

      def run
        loop do
          if @expecting_payload != false
            ##puts "READING PAYLAOD!"
            payload = socket.read @expecting_payload[:size]
            #diff = (Time.now.to_f*1000).to_i - payload.to_i
            #puts " --> PAYLOAD #{@expecting_payload[:sub]}=#{payload} ms=#{diff}"
            #puts " --> ms=#{diff}"
            # notify any interested handlers
            publish 'payload', { sub: @expecting_payload[:sub], payload: payload}
            @expecting_payload = false
          else
            #puts "..."
            handle_message socket.readline(CR_LF)
          end
        end
      end

      def handle_message(line)
        #puts line
        event = decoder.parse line
        case event[:type]
          when EXPECT_PAYLOAD
            ##puts "INCOMING MESSAGE!"
            @expecting_payload = event
            #puts @expecting_payload
          when INFO
            #$#puts "RECEIVED INFO, connecting"
            #@socket.puts encoder.connect verbose: true, pedantic: false
            send_command :connect, verbose: true, pedantic: false
          when OK
            sleep 1
            send_command :ping
          when PING
            send_command :pong
            #@socket.puts encoder.subscribe subject: 'foo', sid: 2
          else
            true
        end
      end

      #def send_data(data)
      #end
#
      #def receive_data(data)
      #end

    end
  end
end
