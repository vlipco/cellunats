module NATS
  module Protocol
    class Driver

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

      MSG_PATTERN      = /\AMSG\s+([^\s]+)\s+([^\s]+)\s+(([^\s]+)[^\S\r\n]+)?(\d+)\r\n/i

      OK_PATTERN       = / \A \+OK \s \r\n* \r\n       /ix.freeze
      ERROR_PATTERN    = / \A -ERR \s+ ('.+')? \r\n    /ix.freeze
      PING_PATTERN     = / \A PING \s* \r\n            /ix.freeze
      PONG_PATTERN     = / \A PONG \s* \r\n            /ix.freeze
      INFO_PATTERN     = / \A INFO \s+ ([^\r\n]+) \r\n /ix.freeze

      INBOX_PATTERN    = /^_INBOX\.\w{13}/.freeze

    end # Driver class
  end # Protocol module
end # NATS module