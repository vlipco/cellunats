module NATS

  class Session

    def initialize
      binding.pry
      @session = Protocol::StateMachine.build
    end

    def connect
      @socket = TCPSocket.new('localhost', 999)
      @session.context = Protocol::Context.new @socket
      @session.context.session = @session
      @session.connect
    end

  end

end