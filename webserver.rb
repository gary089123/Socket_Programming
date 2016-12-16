require "socket"
require "tk" #sudo apt-get install libtcltk-ruby

def gui
  p_server = proc {server}
  p_log = proc {viewlog}

  windows = TkRoot.new do
    title __FILE__.gsub(File.extname(__FILE__),"")
  end
  @portText = TkLabel.new(windows) {
    text "Port:"
    width 8
    height 1
    grid('row'=>0, 'column'=>0, 'columnspan'=>1)
  }
  @portField = TkEntry.new(windows) {
    width 10
    grid('row'=>0, 'column'=>1, 'columnspan'=>3)
  }
  @startstopbutton = TkButton.new(windows){
    text "Start"
    width 10
    grid('row'=>2, 'column'=>0)
    command p_server
  }
  @viewlogbutton = TkButton.new(windows){
    text "View Log"
    width 20
    grid('row'=>2, 'column'=>1)
    command p_log
  }
  @text = Tk::Tile::Notebook.new(windows){
    width 50
    height 10
    grid('row'=>1, 'column'=>0, 'columnspan'=>2)
  }
  f1 = TkFrame.new(@text){
    width 50
    height 10
  }

  @text.add f1, :text => 'Status', :state =>'disabled'

  Tk.mainloop
end



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
  puts "#{__FILE__.gsub(File.extname(__FILE__),"")} is starting on http://localhost:#{@portField.value}"
  puts "Start :  PID = #{Process.pid}  PORT = #{@portField.value}"
  puts "*************************************************************"

end

def viewlog
  Thread.start do
    system("cat ./#{__FILE__.gsub(File.extname(__FILE__),"")}.log")
  end
end

def server
  if @status==false
    Thread.start do
      startinfo
      @webserver = TCPServer.new('localhost', @portField.value.to_i)
      @status=true
      @startstopbutton.text="Stop"
      base_dir = Dir.new(".")
      logStr=String.new
      while (session = @webserver.accept)
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
          puts "session close"
        end
      end
    end

  else
    @webserver.close
    @status=false
    @startstopbutton.text="Start"
  end

end
@status=false
gui
