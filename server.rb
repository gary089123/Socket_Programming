require 'socket'

server = TCPServer.new('localhost',2000)

loop {
  client = server.accept
  client.puts(Time.now.ctime)
  client.puts "Hello world"
  client.close

}
