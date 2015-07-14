module NATS
  # this class handles initialization of the socket
  # and socket write operations and incoming messages notifications
  class Session

    include Celluloid
    include Celluloid::Logger
    include Celluloid::Notifications

    # the IO modules avoids the run loop to block write operations
    # on the socket so that both operations can be handled concurrently
    include Celluloid::IO

    # avoid name collision with the libraries own pub/sub methods
    alias_method :subscribe_to_notifications, :subscribe
    alias_method :publish_notification, :publish

    # this make the blocks passed to subscribe be executed on the
    # context of this class, instead of going to the senders thread
    #execute_block_on_receiver :subscribe
    #execute_block_on_receiver :request

    def initialize
      @socket = Protocol::Socket.new 'localhost', 4222
      @context = Protocol::Context.new @socket
      #@sub_handlers = Hashie::Mash.new
    end

    def new_message(topic, data)
      debug "Handling incoming message to #{data.sub}"
      # TMP see if block make things slow
      diff = Time.now.to_f - data.body.to_f
      puts "#{data.sub} RCV #{diff*1000}"
    end

    def run
      @context.connect
      subscribe_to_notifications @socket.topic, :new_message
      loop do
        async.get_line
      end
    end

    def get_line
      @context.process_line @socket.receive_line
    end

    def publish(sub, msg='', reply: nil)
      msg = msg.to_s
      @socket.push_line PUB, sub, reply, msg.bytesize, CR_LF, msg.to_s
    end

    def subscribe(sub, queue: '')
      debug "Subscribing to #{sub} queue=#{queue}"
      @socket.push_line SUB, sub, queue, next_sid
    end

    def request(sub,msg='')
      inbox = "_INBOX.#{SecureRandom.hex(13)}"
      subscribe inbox
      publish sub, msg, reply: inbox
    end

    # ensure sids are unique per session using a counter
    def next_sid
      @sid ||= 1
      @sid = @sid + 1
    end

    def latency_echo
      request "echo", Time.now.to_f do |response|
        (Time.now.to_f - response.to_f)*1000
      end
    end

    # TODO unsub

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