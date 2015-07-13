module NATS
  module Protocol
    module Constants

      UNKNOWN = 'UNKNOWN'.freeze
      EXPECT_PAYLOAD = 'EXPECT_PAYLOAD'.freeze
      INFO = 'INFO'.freeze
      ERROR = 'ERROR'.freeze
      PONG = 'PONG'.freeze
      CONNECT = 'CONNECT'.freeze
      SUB = 'SUB'.freeze
      OK = 'OK'.freeze
      PUB = 'PUB'.freeze
      UNSUB = 'UNSUB'.freeze
      PING = 'PING'.freeze
      EMPTY = ''.freeze
      CR_LF = "\r\n".freeze
      SPACE = ' '.freeze

      MSG_PATTERN      = %r{
          MSG      \s+    #       the command and spaces
          ([^\s]+) \s+    # 1   - the subject, spaces
          ([^\s]+) \s+    # 2   - the id the client gave to for the subject, spaces
          # the next optional match includes 3, the whole match, and 4, the inner match
          ( (\S+)  \s+ )? # 4   - maybe a reply channel, spaces
          (\d+)           # 5   - the length of the message payload
        }xi.freeze        # case insensitive, ignores whitespace

        OK_PATTERN       = /\+OK\s*/i.freeze
        ERROR_PATTERN    = /-ERR\s+('.+')?/i.freeze
        PING_PATTERN     = /PING\s*/i.freeze
        PONG_PATTERN     = /PONG\s*/i.freeze
        INFO_PATTERN     = /INFO\s+([^\r\n]+)/i.freeze

    end
  end
end