
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

    end
  end
end

require 'encoder'
require 'decoder'