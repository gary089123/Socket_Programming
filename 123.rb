require "socket"

client=TCPServer.new(1234)

while session=client.accept
  request=session.gets
  #session.puts request
  path=request.gsub(/GET\ \//,"").gsub(/\ HTTP.*/,"").chomp
  response="HTTP/1.1 200 OK\r\n\r\n"
  session.print response
  f=File.open(path)
  while !f.eof?
    buffer=f.read(256)
    session.write buffer
  end
  session.close
end
