module NATS

  module Protocol

    class Context

      attr_accessor :session

      def initialize(socket)
        @processed_lines = 0
        @socket = socket
      end

      def open_connection_action
        puts "Opening connection"
      end

      def authenticate_action
        puts "Authenticating!"
        session.listen
      end

      def process_line_action
        @processed_lines = @processed_lines + 1
        if @processed_lines == 3
          puts "!!!!!! READY TO DISCONNECT"
          session.disconnect and return
        end
        puts "processing a line=#{@current_line}"
        @payload_data = "le payload, le size - #{@processed_lines}"
        @current_line = nil
        #binding.pry
        session.expect_payload
      end

      def receive_line_action
        puts "received a line, trigger process"
        @current_line = "aloha"
        session.process_line
      end

      def receive_payload_action
        puts "Reading the amount of bytes of a payload=#{@payload_data}"
        puts "notifying & then listening again"
        session.listen
      end

      def disconnect_action
        puts "DISCONNECTING"
        #byebug
      end

    end

  end

end