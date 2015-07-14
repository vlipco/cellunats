module NATS
  # this class handles initialization of the socket
  # and socket write operations and incoming messages notifications
  class Session

    include Celluloid
    include Celluloid::Logger
    #include Celluloid::Notifications

    # the IO modules avoids the run loop to block write operations
    # on the socket so that both operations can be handled concurrently
    include Celluloid::IO

    # avoid name collision with the libraries own pub/sub methods
    #alias_method :subscribe_to_notifications, :subscribe
    #alias_method :publish_notification, :publish

    # this make the blocks passed to subscribe be executed on the
    # context of this class, instead of going to the senders thread
    #execute_block_on_receiver :subscribe
    #execute_block_on_receiver :request

    def initialize
      @socket = Protocol::Socket.new 'localhost', 4222
      @socket.connect
      async.run
      #@context = Protocol::Context.new @socket
      #@sub_handlers = Hashie::Mash.new
    end

    def new_message(data)
      #debug "Handling incoming message to #{data.sub}"
      # TMP see if block make things slow
      diff = (Time.now.to_f - data.body.to_f)*1000
      info diff.to_i
    end

    def run
      #@context.connect
      #subscribe_to_notifications @socket.topic, :new_message
      loop do
        
          line = @socket.receive_line
          case line
            when MSG_PATTERN
              data = Hashie::Mash.new sub: $1, sid: $2.to_i, reply: $4, msg_size: $5.to_i
              data.body = @socket.read data.msg_size
              async.new_message data
            when PING_PATTERN
              @socket.push_line PONG
            when ERROR_PATTERN
              raise "NATS error: #{$1}"
            #when EMPTY, PONG_PATTERN, OK_PATTERN
            #  true # noop
            else
              true
            #  raise "Unknown NATS command: #{@current_line}"
          end
        
      end
    end

    #def get_line
    #  @context.process_line @socket.receive_line
    #end

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
      async.subscribe inbox, queue: 'workers'
      async.publish sub, msg, reply: inbox
    end

    # ensure sids are unique per session using a counter
    def next_sid
      @sid ||= 1
      @sid = @sid + 1
    end

    def latency_echo
      async.request "echo", Time.now.to_f
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