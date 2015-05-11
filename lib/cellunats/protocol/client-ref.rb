require 'celluloid/io'

module CelluNATS
  module Protocol
    class Client

      include Constants

      include Celluloid::IO

      finalizer :shutdown

      attr_accessor :config, :socket, :encoder, :decoder

      def shutdown
        socket.close if socket
      end


      def initialize(opt={})
        @config = opt
        @expecting_payload = false
        @encoder = Encoder.new
        @decoder = Decoder.new
        @socket = TCPSocket.new '127.0.0.1', '4222'
      end

      def send_command(command, *args)
        socket.write encoder.send command, *args
      end

      def run
        loop do
          decoder << socket.readpartial(4096)
          event = decoder.events.pop
          handle event unless event.nil?         
        end
      end

      private

      def handle(event)
        # TODO handle notifications here
        case event[:type]
          when MESSAGE
            event[:current] = Time.now.to_f
            event[:payload] = event[:payload].to_f
            event[:delay] = (event[:current] - event[:payload]) *1000
            puts event.to_json
          when INFO
            STDERR.puts event[:info]
            send_command :connect, verbose: true, pedantic: false
          when OK
            sleep 1
            send_command :ping
          when PING
            send_command :pong
          when PONG
            send_command :ping
        end
      end

    end
  end
end
