module CelluNATS
  module Protocol
    class Decoder

      include Constants

        # Don't call this if you are expecting a payload
        # in any other cases call it once you received CR_LF
        # with the line _not_ including CR_LF
        def parse(line)
          case line
            when MSG_PATTERN
              { 
                type: EXPECT_PAYLOAD,
                sub: $1, sid: $2.to_i, reply: $4, size: $5.to_i
              }
            when OK_PATTERN;      { type: OK }
            when ERROR_PATTERN;   { type: ERROR, message: $1 }
            when PING_PATTERN;    { type: PING }
            when PONG_PATTERN;    { type: PONG }
            when INFO_PATTERN;    { type: INFO, info: $1 }
            else { type: UNKNOWN }
          end
        end

        private

        MSG_PATTERN      = %r{
          MSG      \s+    #       the command and spaces
          ([^\s]+) \s+    # 1   - the subject, spaces
          ([^\s]+) \s+    # 2   - the id the client gave to for the subject, spaces
          # the next optional match includes 3, the whole match, and 4, the inner match
          ( (\S+)  \s+ )? # 4   - maybe a reply channel, spaces
          (\d+)           # 5   - the length of the message payload
        }xi               # case insensitive, ignores whitespace

        OK_PATTERN       = /\+OK\s*/i
        ERROR_PATTERN    = /-ERR\s+('.+')?/i
        PING_PATTERN     = /PING\s*/i
        PONG_PATTERN     = /PONG\s*/i
        INFO_PATTERN     = /INFO\s+([^\r\n]+)/i 

    end
  end
end