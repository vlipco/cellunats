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
      @subscriptions = Hashie::Mash.new
    end

    def run
      @context.connect
      loop do
        @context.process_line @socket.receive_line
      end
    end

    def publish(subject, msg='', reply_to: nil)
      @socket.push_line PUB, subject, reply_to, msg.bytesize, CR_LF, msg.to_s
    end

    def subscribe(subject, queue: '')
      puts "SUBSCRIBING to #{subject}"
      sid = @subscriptions.keys.length + 1
      @socket.push_line SUB, subject, queue, sid
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