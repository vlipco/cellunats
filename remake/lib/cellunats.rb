$LOAD_PATH.unshift File.dirname(__FILE__)

# external deps
require 'json'
require 'hashie'
require 'socket'
require 'celluloid'
require 'celluloid/io'

# internal deps
require "cellunats/constants"
require "cellunats/context"
require "cellunats/statemachine"
require "cellunats/socket"
require "cellunats/session"