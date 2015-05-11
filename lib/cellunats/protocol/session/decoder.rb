require 'celluloid'
require 'json'




module CelluNATS
  module Protocol
    module Decoder
      include Constants

      #include Celluloid

      #attr_reader :events
#
      #def initialize
      #  @buffer = ''.force_encoding Encoding::ASCII_8BIT
      #  @expecting_payload = false
      #  @events = []
      #end
#
      #def <<(data)
      #  @buffer << data
      #  parse_buffer
      #  true # keep simplest return through the proxy
      #end



      #def process_payload
      #  # check that the payload is complete
      #  needed = @expecting_payload[:size]
      #  return unless @buffer.size >= needed
      #  payload = @buffer.slice! 0, needed
      #  msg_event = {
      #    type: MESSAGE,
      #    payload: payload,
      #    reply: @expecting_payload[:reply],
      #    subscription: @expecting_payload[:subscription],
      #    sid: @expecting_payload[:sid]
      #  }
      #  @expecting_payload = false
      #  @events.push msg_event
      #end


      #def parse_buffer
      #  puts "."
      #  event = case @buffer
      #    when MSG_PATTERN
      #      @expecting_payload = { 
      #        subscription: $1, sid: $2.to_i, reply: $4, size: $5.to_i
      #      }
      #      { type: EXPECT_PAYLOAD }
      #    when OK_PATTERN;      { type: OK }
      #    when ERROR_PATTERN;   { type: ERROR, message: $1 }
      #    when PING_PATTERN;    { type: PING }
      #    when PONG_PATTERN;    { type: PONG }
      #    when INFO_PATTERN
      #      { type: INFO, info: JSON.parse($1) }
      #    else 
      #      # TODO consider protocol error posibility
      #      return
      #  end
      #  @buffer = $'
      #  # TODO symbolize hash keys
      #  if @expecting_payload != false
      #    process_payload
      #  else
      #    @events.push event
      #  end
      #end

    end
  end
end