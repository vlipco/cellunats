require 'celluloid/io'

module CelluNATS
  module Protocol
    class Client

      include Constants

      include Celluloid::IO

      finalizer :shutdown

      attr_accessor :config, :socket

      def shutdown
        socket.close if socket
      end


      def initialize(opt={})
        #@config = opt
        #@expecting_payload = false
        
        @socket = TCPSocket.new '127.0.0.1', '4222'
        @state = define_state_machine
        #---
        #@delays = []
      end

      #def average_delay
      #  delays.reduce(&:+) / delays.size
      #end

      def send_command(command, *args)
        if @connected
          socket.write encoder.send command, *args 
        else
          print "-"
        end
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
            print "<"
            event[:current] = Time.now.to_node_timestamp
            event[:payload] = event[:payload].to_i
            event[:delay] = event[:current] - event[:payload]
            @delays.push event[:delay]
            #puts event.to_json
          when INFO
            STDERR.puts event[:info]
            send_command :connect, verbose: true, pedantic: false
            @connected = true
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
