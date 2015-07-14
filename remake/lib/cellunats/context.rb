module NATS
  module Protocol
    # this class handles the context by interpreting _incoming_ messages
    # since most write operations are handled by the session class
    class Context 

      include Celluloid
      include Celluloid::Logger

      exclusive # avoid concurrent operations on this state

      def connect
        @sm.connect
      end

      def process_line(line)
        #@current_line = line
        @sm.process_line line
      end

      def disconnect
        @sm.disconnect
      end

      def initialize(socket,opt={})
        @socket = socket
        @sm = Protocol::StateMachine.build self # self as context
        @config = opt[:config] || {}
      end

      private

      def connect_action
        opt = Hashie::Mash.new verbose: false, pedantic: false
        cs = { :verbose => opt[:verbose], :pedantic => opt[:pedantic] }
        # TODO add cs[:user] & cs[:pass] support for auth
        raise "Auth not implemented" if @socket.auth_required?
        cs[:ssl_required] = opt[:ssl] if opt[:ssl]
        @socket.push_line CONNECT, cs.to_json
        @socket.expect_ok if opt.verbose
        debug "NATS connection established"
        @sm.wait_line # transition to a connected state
      end

      def process_line_action(line)
        case line
          when MSG_PATTERN
            data = Hashie::Mash.new sub: $1, sid: $2.to_i, reply: $4, msg_size: $5.to_i
            debug "Expecting NATS payload: #{data.to_h}"
            @sm.receive_payload data
          #when OK_PATTERN
          #  debug "Received NATS OK"
          #  true # noop
          when ERROR_PATTERN
            raise "NATS error: #{$1}"
          when PING_PATTERN
            debug "Received NATS PING, replying with PONG"
            @socket.push_line PONG
          #when PONG_PATTERN
          #  debug "Received NATS PONG"
          #  true # noop
          when EMPTY, PONG_PATTERN, OK_PATTERN
            true # noop
          else
            #true
            raise "Unknown NATS command: #{@current_line}"
        end
      end

      def receive_payload_action(data)
        data.body = @socket.read data.msg_size
        data.body = Time.now.to_f # TMP: to see time until real arrival
        debug "Message received: #{data.to_h}"
        Celluloid::Notifications.publish @socket.topic, data
        @sm.wait_line
      end

      def disconnect_action
        debug "DISCONNECTING"
      end

    end # Context class
  end # Protocol module
end # NATS module