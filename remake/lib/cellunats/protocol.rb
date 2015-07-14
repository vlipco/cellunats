module NATS


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

  INBOX_PATTERN    = /^_INBOX\.\w{13}/.freeze


  module Protocol 

    def self.encode(*elements)
      elements.push CR_LF # All commands end with the control line
      elements.map! do |e| 
        case e
          when CR_LF; CR_LF
          when EMPTY, SPACE, nil; nil
          else [e]
        end
      end
      encoded = elements.flatten.compact.join(SPACE)
      encoded.gsub("#{SPACE}#{CR_LF}", CR_LF).gsub("#{CR_LF}#{SPACE}", CR_LF)
    end

  end # Protocol module

end # NATS module