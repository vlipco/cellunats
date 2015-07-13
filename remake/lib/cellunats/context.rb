module NATS
  module Protocol
    # this class handles the context by interpreting _incoming_ messages
    # since most write operations are handled by the session class
    class Context 

      include Protocol::Constants
      include Celluloid::Logger


      # access to StateMachine for events
      # and to the socket for socket operations
      attr_reader :current_line

      # delegate missing methods to the statemachine
      # this allows external triggering of events on the sm
      #def method_missing(event)
      #  @sm.send event
      #end

      def connect
        @sm.connect
      end

      def process_line(line)
        @current_line = line
        @sm.process_line
      end

      def disconnect
        @sm.disconnect
      end


      def initialize(socket,opt={})
        @socket = socket
        # build the statemachine with self as the context
        @sm = Protocol::StateMachine.build self
        @config = opt[:config] || {}
        @processed_lines = 0
        @current_line = nil
      end

      private

      def receive_server_info_action
        if @socket.receive_line =~ INFO_PATTERN
          @server_info = Hashie::Mash.new JSON.parse($1)
          debug "Server INFO: #{@server_info}"
        else
          raise "NATS protocol error, expecting INFO but received: #{info_command}"
        end
      end

      def establish_connection_action
        opt = { verbose: true, pedantic: false }
        cs = { :verbose => opt[:verbose], :pedantic => opt[:pedantic] }
        # TODO add cs[:user] & cs[:pass] support for auth
        raise "Auth not implemented" if @server_info.auth_required
        cs[:ssl_required] = opt[:ssl] if opt[:ssl]
        @socket.push_line CONNECT, cs.to_json
        @socket.expect_ok # wait for the server's ACK
        debug "NATS connection established"
        @sm.wait_line # transition to a connected state
      end

      def process_line_action
        if @current_line.nil?
          raise "NATS protocol context error: trying to process with current_line being nil"
        end
        case @current_line
          when MSG_PATTERN
            @payload_data = { sub: $1, sid: $2.to_i, reply: $4, size: $5.to_i }
            debug "Expecting NATS payload: #{@payload_data}"
            @sm.expect_payload
          when OK_PATTERN
            debug "Received NATS OK"
            true # noop
          when ERROR_PATTERN
            raise "NATS error: #{$1}"
          when PING_PATTERN
            debug "Received NATS PING, replying with PONG"
            @socket.push_line PONG
          when PONG_PATTERN
            debug "Received NATS PONG"
            true # noop
          when EMPTY
            true # noop
          else
            raise "Unknown NATS command: #{@current_line}"
        end # case matching
        # TODO count bytes as well?
        @processed_lines = @processed_lines + 1
        @current_line = nil
      end

      def receive_payload_action
        payload_body = @socket.read @payload_data[:size]
        info "PAYLOAD: #{payload_body}"
        #debug "Reading the amount of bytes of a payload=#{@payload_data}"
        #debug "notifying & then listening again"
        @sm.wait_line
      end

      def disconnect_action
        debug "DISCONNECTING"
      end

    end # Context class
  end # Protocol module
end # NATS module