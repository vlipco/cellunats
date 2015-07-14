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

    def unsubscribe(opt)
      opt[:max] ||= EMPTY
      @socket.push_line UNSUB, opt[:sid], opt[:max].to_s
    end

    def ping
      @socket.push_line PING
    end

    def pong
      puts "PONG!!!"
    end