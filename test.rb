require "socket"


def contentType(path)
  type=File.extname(path).gsub('.','')
  if type=="html" || type=="css"
    return "text/"+type
  elsif type=="jpg" || type=="jpeg"
    return "image/jpeg"
  else
    return "text/html"
  end
end

def log(logStr)
  logStr = "\n\n================================================\n#{logStr}"
  logfilename="#{__FILE__.gsub(File.extname(__FILE__),"")}.log"
  if File.exist?("./#{logfilename}")
    logfile=File.open("./#{logfilename}","w+")
  else
    logfile=File.new("./#{logfilename}","w+")
  end
  logfile.write("123")
end


puts "#{__FILE__.gsub(File.extname(__FILE__),"")} is starting on http://localhost:2000"
webserver = TCPServer.new('localhost', 2000)
base_dir = Dir.new(".")
logStr=String.new
while (session = webserver.accept)
  Thread.start do
    request=session.gets
    puts "Connection from #{session.peeraddr[2]} at #{session.peeraddr[3]}"
    logStr =  "#{session.peeraddr[2]} (#{session.peeraddr[3]})\n"
    logStr += Time.now.localtime.strftime("%Y/%m/%d %H:%M:%S")
    logStr += "\n#{request}"
    method=request.gsub(/\ \/.*/,'').chomp
    if method=="GET"
      request_path = request.gsub(/GET\ \//, '').gsub(/\ HTTP.*/, '').chomp
    elsif method=="POST"
      request_path = request.gsub(/POST\ \//, '').gsub(/\ HTTP.*/, '').chomp
    end

    if request_path==""
      request_path="."
    end

    if File.directory?(request_path)
      base_dir = Dir.new(request_path)
      base_dir.entries.each do |f|
        if File.basename(__FILE__)==f
          # do nothing
        elsif File.directory?(f)
          session.print "#{f}/\r\n"
        else
          session.print "#{f}\r\n"
        end
      end
    elsif !File.exist?(request_path)
      session.print "404 - Resource Cannot be Found"
    else
      contentType=contentType(request_path)
      session.print "HTTP/1.1 200/OK\r\nContent-type: #{contentType}\r\n\r\n"
      File.open(request_path) do |f|
        while (!f.eof?) do
          buffer = f.read(256)
          session.write(buffer)
        end
      end
    end
    log(logStr)

    session.close
  end

end
