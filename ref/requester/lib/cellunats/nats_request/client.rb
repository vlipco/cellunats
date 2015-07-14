require 'socket'
Thread.abort_on_exception = true
require 'securerandom'

module NATS
  module Protocol
    class Client

      include Constants
      attr_accessor :config, :socket, :encoder, :decoder

      def initialize(opt={})
        @config = opt
        @expecting_payload = false
        @encoder = Encoder.new
        @decoder = Decoder.new
        @inbox = "_INBOX.#{SecureRandom.hex(13)}"
        @topic = 'help'
        @message = ''
        create_socket
      end

      def create_socket
        BasicSocket.do_not_reverse_lookup = false
        if ENV['NATS_SERVER']
          full = ENV['NATS_SERVER']
          full.gsub! "nats://", ""
          server, port = full.split ":"
        else
          server = '127.0.0.1'
          port = '4222'
        end
        @socket = TCPSocket.new server, port
      end

      def send_command(command, *args)
        cmd = encoder.send command, *args
        socket.puts cmd
      end

      attr_accessor :worker

      def single_request(topic, message='')
        payload = -1
        mutex = Mutex.new
        loop_locked = false
        @worker = Thread.new do
          mutex.lock
          loop_locked = true
            loop do
              if @expecting_payload != false
                payload = socket.read @expecting_payload[:size]
                @expecting_payload = false
                mutex.unlock
                break
              else
                handle_message socket.readline(CR_LF)
              end
            end
            socket.close
        end
        until loop_locked
          true # ensure coordination
        end
        mutex.lock
        return payload
      end

      def handle_message(line)
        event = decoder.parse line
        case event[:type]
          when EXPECT_PAYLOAD
            @expecting_payload = event
          when INFO
            send_command :connect, verbose: true, pedantic: false
          when OK
            send_command :subscribe, subject: @inbox, sid: 2
            send_command :publish, subject: @topic, msg: @message, reply: @inbox
            #sleep 1
            #send_command :ping
          when PING
            send_command :pong
          else
            true
        end
      end

    end
  end
end
