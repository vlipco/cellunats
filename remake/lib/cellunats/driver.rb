$LOAD_PATH.unshift File.dirname(__FILE__)

require 'hashie'
require 'json'

module NATS
  module Protocol
    class Driver

      def initialize
        @waiting_control_line = true
        @buf = ""
        @msg = nil
      end

    end
  end
end

require 'driver/constants'
require 'driver/parse'