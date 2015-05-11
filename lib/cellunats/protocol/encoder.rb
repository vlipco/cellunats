require 'json'

module CelluNATS
  module Protocol
    class Encoder

      include Constants

      def connect(opt) 
        cs = { :verbose => opt[:verbose], :pedantic => opt[:pedantic] }
        # TODO add user
        #if auth_connection?
        #  cs[:user] = @uri.user if @uri.user
        #  cs[:pass] = @uri.password if @uri.password
        #end
        cs[:ssl_required] = opt[:ssl] if opt[:ssl]
        encode CONNECT, cs.to_json
      end

      def ping
        encode PING
      end

      def pong
        encode PONG
      end

      # TODO options  default
      def publish(opt)
        raise EncodeError.new "Subject is missing" unless opt[:subject]
        #opt[:reply] ||= EMPTY
        opt[:message] ||= ''
        opt[:message] = opt[:message].to_s # be permissive on the type
        encode PUB, opt[:subject], opt[:reply], opt[:message].bytesize, CR_LF, opt[:message]
      end

      def subscribe(opt)
        raise EncodeError.new "Subject is missing" unless opt[:subject]
        opt[:queue] ||= EMPTY # empty by default
        encode SUB, opt[:subject], opt[:queue], opt[:sid]
      end

      # Cancel a subscription.
      # @param [Object] sid
      # @param [Number] opt_max, optional number of responses to receive before auto-unsubscribing
      def unsubscribe(opt)
        opt[:max] ||= EMPTY
        encode UNSUB, opt[:sid], opt[:max].to_s
      end

      private

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
        elements.join(EMPTY).gsub "#{SPACE}#{CR_LF}", CR_LF
      end

      #end
    end
  end
end