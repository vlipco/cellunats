module NATS
  # this class handles initialization of the socket
  # and socket write operations and incoming messages notifications
  class Session

    include Protocol::Constants
    include Celluloid

    def run
      @socket = Protocol::Socket.new 'localhost', 4222
      subscribe subject: "foo", sid: 2
      @socket.run
      #byebug
      #loop { true }
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