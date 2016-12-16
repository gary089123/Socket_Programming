require "socket"

client=TCPServer.new(1234)

while session=client.accept
  request=session.gets
  session.puts request
  request.gsub(/GET\ \//,"").gsub("")
  session.close
end
