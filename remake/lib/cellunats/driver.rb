$LOAD_PATH.unshift File.dirname(__FILE__)

require 'hashie'
require 'json'
require 'securerandom'

module NATS
  module Protocol
    class Driver
      
      attr_reader :server_info, :disconnected

      # todo receive connection configuration

      def initialize(socket)
        @socket = socket
        @disconnected = true
        @server_info = nil
        @waiting_control_line = true
        @buf = ""
        @msg = nil
        @sid = 1
      end

      def publish(sub, msg='', reply: nil)
        msg = msg.to_s
        write PUB, sub, reply, msg.bytesize, CR_LF, msg.to_s
      end

      def subscribe(sub, queue: '')
        #debug "Subscribing to #{sub} queue=#{queue}"
        write SUB, sub, queue, next_sid
      end

      def request(sub,msg='')
        inbox = "_INBOX.#{SecureRandom.hex(13)}"
        subscribe inbox, queue: 'workers'
        publish sub, msg, reply: inbox
      end

      def unsubscribe(opt)
        opt[:max] ||= EMPTY
        write UNSUB, opt[:sid], opt[:max].to_s
      end

      private

      def connect
        puts "CONNECTING"
        #byebug
        raise "Missing server info, is the socket already open?" unless @server_info
        opt = Hashie::Mash.new verbose: false, pedantic: false
        cs = { :verbose => opt[:verbose], :pedantic => opt[:pedantic] }
        # TODO add cs[:user] & cs[:pass] support for auth
        raise "Auth not implemented" if @server_info.auth_required
        cs[:ssl_required] = opt[:ssl] if opt[:ssl]
        write CONNECT, cs.to_json, force: true
        @disconnected = false
        puts "READY!"
      end

      def notify_message
        Celluloid::Notifications.notifier.publish "nats:#{@socket.__id__}", @msg
        @msg = nil
      end

      def next_sid
        @sid = @sid + 1
      end

    end
  end
end

require 'driver/constants'
require 'driver/parse'
require 'driver/encode'