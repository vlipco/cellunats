require 'thread'
require 'socket'

socket = TCPSocket.new "localhost", "9292"

reader = Thread.new do
  puts "READING"
  result = socket.readline
  puts "READ LINE: #{result}"
end

puts "WRITING!"
socket.write "ALOHA!"
puts "done."

loop { true }