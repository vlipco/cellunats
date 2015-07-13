module NATS
  # this class handles initialization of the socket
  # and socket write operations and incoming messages notifications
  class Session

    include Protocol::Constants
    include Celluloid

    # the IO modules avoids the run loop to block write operations
    # on the socket so that both operations can be handled concurrently
    include Celluloid::IO


    def initialize
      @socket = Protocol::Socket.new 'localhost', 4222
      @context = Protocol::Context.new @socket
    end

    def run
      @context.connect
      loop do
        @context.process_line @socket.receive_line
      end
    end

    # TODO options  default
    def publish(opt)
      raise EncodeError.new "Subject is missing" unless opt[:subject]
      #opt[:reply] ||= EMPTY
      opt[:msg] ||= ''
      @socket.push_line PUB, opt[:subject], opt[:reply], 
        opt[:msg].bytesize, CR_LF, opt[:msg].to_s
    end

    def subscribe(opt)
      raise EncodeError.new "Subject is missing" unless opt[:subject]
      opt[:queue] ||= EMPTY # empty by default
      puts "SUBSCRIBING to #{opt}"
      @socket.push_line SUB, opt[:subject], opt[:queue], opt[:sid]
    end

    def request(opt)
      "_INBOX.#{SecureRandom.hex(13)}"
    end

    # Cancel a subscription.
    # @param [Object] sid
    # @param [Number] opt_max, optional number of responses to receive before auto-unsubscribing
    def unsubscribe(opt)
      opt[:max] ||= EMPTY
      @socket.push_line UNSUB, opt[:sid], opt[:max].to_s
    end

    def ping
      @socket.push_line PING
    end

  end # Session class
end # NATS module