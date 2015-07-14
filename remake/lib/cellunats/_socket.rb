module NATS
  #module Protocol
    class Socket < Celluloid::IO::TCPSocket

      include Celluloid::Logger

      # -----------

     

      # ------------

      

      def topic
        "#{__id__}:messages"
      end

      # TODO make this cache command if the connection isn't ready
      # OPTIONAL handle write buffer through the context to centralize ops?
      def push_line(*commands)
        encoded_line = Protocol.encode commands
        #debug "<- #{encoded_line.chomp}"
        puts encoded_line
      end

      def receive_line
        @processed_lines ||= 0
        incoming_line = readline(CR_LF).chomp
        #debug "-> #{incoming_line}" unless incoming_line == EMPTY
        @processed_lines = @processed_lines + 1
        return incoming_line
      end

    end # Socket class
  #end # Protocol module
end # NATS module