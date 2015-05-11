require 'json'

module CelluNATS
  module Protocol
    module Encoder

      include Constants

      def send_connect(opt={}) 
        opt[:verbose] = true
        opt[:pedantic] = false
        cs = { :verbose => opt[:verbose], :pedantic => opt[:pedantic] }
        # TODO add user
        #if auth_connection?
        #  cs[:user] = @uri.user if @uri.user
        #  cs[:pass] = @uri.password if @uri.password
        #end
        cs[:ssl_required] = opt[:ssl] if opt[:ssl]
        # this is not a queued command
        cmd = encode CONNECT, cs.to_json
        $logger.debug "Connecting with: #{cmd}"
        socket.puts cmd
        read_command
      end

      def send_ping
        enqueue encode PING
      end

      def send_pong
        enqueue encode PONG
      end

      # TODO options  default
      def send_publish(opt)
        raise EncodeError.new "Subject is missing" unless opt[:subject]
        #opt[:reply] ||= EMPTY
        opt[:message] ||= ''
        opt[:message] = opt[:message].to_s # be permissive on the type
        enqueue encode PUB, opt[:subject], opt[:reply], opt[:message].bytesize, CR_LF, opt[:message]
      end

      def send_subscribe(opt)
        raise EncodeError.new "Subject is missing" unless opt[:subject]
        opt[:queue] ||= EMPTY # empty by default
        enqueue encode SUB, opt[:subject], opt[:queue], opt[:sid]
      end

      # Cancel a subscription.
      # @param [Object] sid
      # @param [Number] opt_max, optional number of responses to receive before auto-unsubscribing
      def send_unsubscribe(opt)
        opt[:max] ||= EMPTY
        enqueue encode UNSUB, opt[:sid], opt[:max].to_s
      end

      private

      def enqueue(cmd)
        $logger.debug "Enqueueing: #{cmd}"
        @pending.push cmd
        if session.state == :waiting_payload
          $logger.debug "Deferring flush until payload arrives"
        else
          flush_pending 
        end
      end

      def encode(*elements)
        elements.push CR_LF # All commands end with the control line
        elements.map! do |e| 
          case e
            when CR_LF; CR_LF
            when EMPTY, SPACE, nil; nil
            else [e, ' ']
          end
        end
        elements.flatten!.compact!
        elements.join(EMPTY).gsub("#{SPACE}#{CR_LF}", CR_LF)
      end

      #end
    end
  end
end