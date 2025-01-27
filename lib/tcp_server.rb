require 'socket'
require_relative 'request'
require_relative 'router'
require 'mime-types'

PUBLIC_DIR = File.expand_path("../public", __dir__)

class HTTPServer

    def initialize(port)
        @port = port
    end

    def start
        server = TCPServer.new(@port)
        puts "Listening on #{@port}"
        router = Router.new
        router.add_route(:get, "/banan") do
            File.read("views/index.html")
        end
        router.add_route(:get, "/senap") do
            "<h1>SENAP</h1>"
        end


        while session = server.accept
            data = ""
            while line = session.gets and line !~ /^\s*$/
                data += line
            end
            puts "RECEIVED REQUEST"
            puts "-" * 40
            puts data
            puts "-" * 40

            request = Request.new(data)
            # pp request
            matching_route = router.match_route(request)
            # if matching_route
            #     response = Response.new(matching_route, session)
            # elsif #kolla om filen finns i public
            #     filen = ....
            #     response = Response.new(filen, session)
            # else
            #     data = "Oh noes"
            #     response = Response.new(data, session, 404)
            # end

            if matching_route
                response = Response.new(matching_route[:block].call, session)
            else
                file_path = File.join(PUBLIC_DIR, request.resource)
            if File.exist?(file_path) && File.file?(file_path)
                    response = Response.new(file_path, session, file: true)
            else
                    #404 Not found
                    response = Response.new("Oh noes", session, status: 404)
            end
        end


            response.send

        end
    end
end

class Response

    def initialize(result, session, file: false, status: 200)
        @session = session
        @result = result
        @status = status
        @file = file
    end


    def send
        # if @result
        #     content_type = "text/html"
        #     content = @result[:block].call

        # elsif File.exist?(file_path)
        #     file_path = File.join(PUBLIC_DIR, request.resource)
        #     content_type = MIME::Types.type_for(file_path).first.to_s || "application/octet-stream"
        #     content = File.binread(file_path)
        # else
        #   content_type = "text/html"
        #   content = "<h1>No found</h1>"
        # end

        if @file
            content_type = MIME::Types.type_for(@result).first.to_s || "application/octet-stream"
            content = File.binread(@result)
        else
          content_type = "text/html"
          content = @result
        end


        @session.print "HTTP/1.1 #{@status}\r\n"
        @session.print "Content-Type: #{content_type}\r\n"
        @session.print "Content-Length: #{content.bytesize}\r\n"
        @session.print "\r\n"
        @session.print content
        @session.close
    end

    private

  def status_message
    case @status
    when 200 then "OK"
    when 404 then "Not Found"
    when 500 then "Internal Server Error"
    else "Unknown"
    end
  end
end

server = HTTPServer.new(4567)
server.start
