$LOAD_PATH.unshift File.dirname(__FILE__)

# external deps
require 'json'
require 'hashie'
require 'socket'

#require 'celluloid/current'
require 'celluloid'
require 'celluloid/io'

require 'statemachine'
require 'securerandom'

# internal deps
require "cellunats/driver"
#require "cellunats/protocol"
#require "cellunats/context"
#require "cellunats/statemachine"
#require "cellunats/socket"
#require "cellunats/session"