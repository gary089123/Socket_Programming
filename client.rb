require 'socket'

hostname = 'localhost'
port = 2000

tcp = TCPSocket.new(hostname, port)
while line = tcp.gets
  puts line.chop
end
tcp.close
