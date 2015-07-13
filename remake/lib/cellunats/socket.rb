module NATS
  module Protocol
    class Socket < Celluloid::IO::TCPSocket

      #include Protocol::Constants
      include Celluloid::Logger

      def expect_ok
        incoming = receive_line
        if incoming =~ OK_PATTERN
          return true  
        else
          raise "NATS protocol error: expected OK but received [#{incoming}]"
        end
      end

      def topic
        "#{@socket.__id__}:messages"
      end

      # TODO make this cache command if the connection isn't ready
      # OPTIONAL handle write buffer through the context to centralize ops?
      def push_line(*commands)
        encoded_line = Protocol.encode commands
        debug "<- #{encoded_line.chomp}"
        puts encoded_line
      end

      def receive_line
        incoming_line = readline(CR_LF).chomp
        debug "-> #{incoming_line}" unless incoming_line == EMPTY
        incoming_line
      end

    end # Socket class
  end # Protocol module
end # NATS module