module NATS
  module Protocol
    class Socket < Celluloid::IO::TCPSocket

      include Protocol::Constants
      include Celluloid::Logger

      def initialize(host,port)
        super host, port
        # build the context and pass this socket
        @context = Context.new self
      end

      def run
        @context.connect
        loop do
          #@context.current_line = receive_line
          @context.process_line receive_line
        end
      end

      def expect_ok
        incoming = receive_line
        if incoming =~ OK_PATTERN
          return true  
        else
          raise "NATS protocol error: expected OK but received [#{incoming}]"
        end
      end

      # TODO make this async
      # OPTIONAL handle write buffer through the context to centralize ops?
      def push_line(*commands)
        encoded_line = encode commands
        debug "<- #{encoded_line.chomp}"
        puts encoded_line
      end

      def receive_line
        incoming_line = readline(CR_LF).chomp
        debug "-> #{incoming_line}" unless incoming_line == EMPTY
        incoming_line
      end

      def encode(*elements)
        elements.push CR_LF # All commands end with the control line
        elements.map! do |e| 
          case e
            when CR_LF; CR_LF
            when EMPTY, SPACE, nil; nil
            else [e, SPACE]
          end
        end
        elements.flatten!.compact!
        elements.join(SPACE).gsub "#{SPACE}#{CR_LF}", CR_LF
      end

    end # Socket class
  end # Protocol module
end # NATS module