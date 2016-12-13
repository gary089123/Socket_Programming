require "socket"


def contentType(path)

  type=File.extname(path).gsub('.','')
  if type=="html" || type=="css"
    return "text/"+type
  elsif type=="jpg" || type=="jpeg"
    return "image/jpeg"
  elsif type=="gif"
    return "image/gif"
  else
    return "text/html"
  end

end

def log(logStr)

  logStr = "#{logStr}-----------------------------------------------\n\n"
  logfilename="#{__FILE__.gsub(File.extname(__FILE__),"")}.log"

  if File.exist?("./#{logfilename}")
    logfile=File.open("./#{logfilename}","a")
  else
    logfile=File.new("./#{logfilename}","w")
  end

  logfile.puts logStr
  logfile.close

end

def startinfo

  puts "*************************************************************"
  puts "#{__FILE__.gsub(File.extname(__FILE__),"")} is starting on http://localhost:2000"
  puts "Start :  PID = #{Process.pid}  PORT = 2000"
  puts "*************************************************************"

end

startinfo
webserver = TCPServer.new('localhost', 2000)
base_dir = Dir.new(".")
logStr=String.new
while (session = webserver.accept)
  Thread.start do
    request=session.gets
    puts "Connection from #{session.peeraddr[2]} at #{session.peeraddr[3]}"
    logStr =  "Connection: #{session.peeraddr[2]} (#{session.peeraddr[3]})\n"
    logStr += "Time      : "+Time.now.localtime.strftime("%Y/%m/%d %H:%M:%S")+"\n"
    logStr += "Request   : #{request}"
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
        if File.basename(__FILE__).gsub(/\..*/,"")==File.basename(f).gsub(/\..*/,"")
          # do nothing
        elsif File.directory?(f)
          session.print "#{f}/\r\n"
        else
          session.print "#{f}\r\n"
        end
      end

    elsif !File.exist?(request_path)
      session.print "404 - Resource Cannot be Found"
      logStr += "Response  : 404 - Resource Cannot be Found\n"

    else
      contentType=contentType(request_path)
      session.print "HTTP/1.1 200/OK\r\nContent-type: #{contentType}\r\n\r\n"
      puts "HTTP/1.1 200/OK  Content-type: #{contentType}"
      logStr += "Response  : HTTP/1.1 200/OK  Content-type: #{contentType}\n"
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
