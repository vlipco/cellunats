module NATS
  module Protocol 
    class Driver

      def parse(data)
        @buf = @buf ? @buf << data : data
        while @buf
          if @waiting_control_line
            case @buf
              when MSG_PATTERN
                @msg = Hashie::Mash.new sub: $1, sid: $2.to_i, reply: $4, bytesize: $5.to_i
                @buf = $'
                @waiting_control_line = false
              when INFO_PATTERN
                @buf = $'
                @server_info = Hashie::Mash.new JSON.parse($1)
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
                return
            end
            # if this is empty, set to nil to close the loop
            @buf = nil if (@buf && @buf.empty?)
          else # waiting for payload
            return unless @buf.bytesize >= (@msg.bytesize + CR_LF.bytesize)
            @msg.body = @buf.slice(0, @msg.bytesize) # take the amount from the buffer
            @buf = @buf.slice (@msg.bytesize + CR_LF.bytesize), @buf.bytesize
            @waiting_control_line = true
            notify_message
          end
        end
      end

    end
  end
end