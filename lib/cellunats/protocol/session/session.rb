#require 'celluloid/io'

class Hash
  def symbolize!
    self.keys.each do |k|
      self[k.to_sym] = fetch(k)
      delete k
    end
  end

  def symbolize
    inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
  end
end

require 'constants'
require 'encoder'
require 'decoder'
require 'state'

require 'json'


module CelluNATS
  module Protocol


    class Session #< Celluloid::IO::TCPSocket

      include Celluloid::IO

      attr_reader :info, :socket, :session, :pending

      include Encoder
      include Decoder

      def initialize
        @socket = TCPSocket.new '127.0.0.1', '4222'
        @session = new_protocol_machine
        @pending = [] # tracks the data to send over the socket
      end

      def state
        session.state
      end

      # obtain the server information to start a session
      def read_info
        incoming_line = readline
        if incoming_line =~ INFO_PATTERN
          @info = JSON.parse($1).symbolize.freeze
          session.info # transition state to connecting
          $logger.debug "Server INFO: #{info}"
        else
          raise "PROTOCOL ERROR, EXPECTED INFO BUT GOT #{incoming_line}"
        end
      end

      def readline
        $logger.debug "[#{session.state}] Reading line from socket"
        incoming_line = @socket.readline CR_LF
        $logger.debug "Received: #{incoming_line}"
        incoming_line
      end

      def read_command
        incoming_line = readline
        $logger.debug "Parsing command: #{incoming_line}"
        case incoming_line
          when OK_PATTERN
            if session.state == :connecting
              $logger.debug "Connection established" 
            end
            session.ok
          when PING_PATTERN
            session.ping
          when PONG_PATTERN
            #$logger.debug "Received PONG"
            session.pong
          when MSG_PATTERN
            session.message({subscription: $1, sid: $2.to_i, reply: $4, size: $5.to_i})
          else 
            # ignore if this was empty space
            unless incoming_line.chop.empty?
              $logger.warn "UNEXPECTED: #{incoming_line}"
            end
        end
        $logger.debug "*********** ---"
      end

      def receive_payload(payload)
        $logger.debug "Receiving payload in '#{payload[:subscription]}' subscription"
        subscription = payload[:subscription]
        payload[:payload] = socket.read payload[:size]
        $logger.debug "Payload: #{payload[:payload]}"
        session.notify_message payload
      end

      def notify_message(msg)
        msg[:current] = (Time.now.to_f*1000).to_i
        msg[:payload] = msg[:payload].to_i
        msg[:delay] = (msg[:current] - msg[:payload]).to_i
        $logger.debug "RECEIVED: #{msg}"
        if msg[:delay] > 10
          $logger.info "DELAY: #{msg[:delay]}ms"
        end
      end

      def connected?
        ![:disconnected, :reading_info, :connecting].include? session.state
      end

      def flush_pending
        unless pending.empty? || !connected?
          $logger.debug "Flushing pending commands: #{pending.join(', ')}"
          socket.puts pending.join
          @pending = []
          #read_command
        end
      end

      attr_reader :session

    end
  end
end
