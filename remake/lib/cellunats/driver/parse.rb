module NATS
  module Protocol 
    class Driver

      def parse(data)
        #puts "****************** PROCESSING: #{data}"
        @buf << data
        until @buf.empty?
          if @waiting_control_line
            case @buf
              when MSG_PATTERN
                @msg = Hashie::Mash.new sub: $1, sid: $2.to_i, reply: $4, payload_size: $5.to_i
                #byebug
                @buf = $'
                #byebug
                @waiting_control_line = false
                #@needed = 
#                puts "WAITING PAYLOAD"
              when INFO_PATTERN
                @buf = $'
                @server_info = Hashie::Mash.new JSON.parse($1)
                connect
              when PING_PATTERN
                @buf = $'
                write PONG
                #@socket.push_line PONG
              when ERROR_PATTERN
                raise "NATS error: #{$1}"
              when PONG_PATTERN
                # TODO notify this in some way, can be used for liveness test
                @buf = $'
              when OK_PATTERN
                @buf = $' # remove the noop line from the buffer
              else # we cannot fully understand the line, more data required
                #binding.pry
                #puts "----- #{@buf}"
                return
            end
            # if this is empty, set to nil to close the loop
            #@buf = nil if (@buf && @buf.empty?)
          else # waiting for payload
            #puts "GETTING PAYLOAD"
            #byebug
            return unless @buf.bytesize >= (@msg.payload_size + CR_LF.bytesize)
            #puts "BUFFER ENOUGH!"
            @msg.body = @buf.slice(0, @msg.payload_size) # take the amount from the buffer
            @buf = @buf.slice (@msg.payload_size + CR_LF.bytesize), @buf.bytesize
            @waiting_control_line = true
            #puts "+msg"
            notify_message
            #puts "*****************"
          end
        end
      end

    end
  end
end