require "socket"

client=TCPServer.new(4000)

while session=client.accept
  request=session.gets
  request_path=request.gsub(/GET\ \//,"").gsub(/\ HTTP.*/,"").chomp
  puts request_path
  response = "HTTP/1.1 200 OK\r\n\r\n"
  session.print response
  f=File.open(request_path)
  while !f.eof?
    buffer = f.read(256)
    session.write(buffer)
    puts buffer
  end
  session.close
end
