module NATS
  class Session

    include Celluloid::IO
    include Celluloid::Notifications

    alias_method :cell_sub, :subscribe
    alias_method :cell_pub, :publish

    attr_reader :socket, :driver # TMP

    def message_handler(topic, msg)
      diff = (Time.now.to_f*1000).to_i - msg.body.to_i
      puts "Latency: #{diff.to_i}"
    end

    def initialize
      @socket = TCPSocket.new 'localhost', '4222'
      cell_sub "nats:#{@socket.__id__}", :message_handler
      #@d = NATS::Protocol::Driver.new @socket
      @driver = NATS::Protocol::Driver.new @socket
      async.run
    end

    def run
      loop do
        begin
          data = @socket.readpartial(1024)
          #fdata = data.gsub "\r\n", '|'
          #puts "> #{fdata}"
          #puts "..."
          @driver.parse data
          #puts "..."
        rescue EOFError
          raise "CONNECTION CLOSED"
          break
        end
      end
    end

  end
end