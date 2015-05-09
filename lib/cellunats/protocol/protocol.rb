
module CelluNATS
  module Protocol

    module Constants

      UNKNOWN = 'UNKNOWN'.freeze
      MESSAGE = 'MESSAGE'.freeze
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

      MAX_PENDING_SIZE = 32768

      MSG_PATTERN      = %r{
        MSG      \s+    #       the command and spaces
        ([^\s]+) \s+    # 1   - the subject, spaces
        ([^\s]+) \s+    # 2   - the id the client gave to for the subject, spaces
        # the next optional match includes 3, the whole match, and 4, the inner match
        ( (\S+)  [^\S\r\n]+ )? # 4   - maybe a reply channel, spaces
        (\d+)           # 5   - the length of the message payload
        \r\n # contorl line CR_LF
      }xi               # case insensitive, ignores whitespace

      OK_PATTERN       = %r{ \+ OK \s* #{CR_LF} }xi
      ERROR_PATTERN    = %r{ -ERR \s+ ('.+')? #{CR_LF} }xi
      PING_PATTERN     = %r{ PING \s* #{CR_LF} }xi
      PONG_PATTERN     = %r{ PONG \s* #{CR_LF} }xi
      INFO_PATTERN     = %r{ INFO \s+([^\r\n]+) #{CR_LF} }xi 

    end


  end
end

require 'encoder'
require 'decoder'