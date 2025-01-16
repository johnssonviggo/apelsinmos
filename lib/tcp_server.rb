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
            "<h1>#{1 + 2}BANAN</h1>
            <img src='/img/bird-with-arms.jpg'>
            <img src='/img/raft.png'>"
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
            result = router.match_route(request)

            file_path = File.join(PUBLIC_DIR, request.resource)

            if result
                status = 200
                content_type = "text/html"
                content = result[:block].call
                p request
                p "här"
            elsif File.exist?(file_path)
                status = 200
                content_type = MIME::Types.type_for(file_path).first.to_s || "application/octet-stream"
                content = File.binread(file_path)
            else
              status = 404
              content_type = "text/html"
              content = "<h1>No found</h1>"
            end


            session.print "HTTP/1.1 #{status}\r\n"
            session.print "Content-Type: #{content_type}\r\n"
            session.print "Content-Length: #{content.bytesize}\r\n"
            session.print "\r\n"
            session.print content
            session.close
        end
    end
end

server = HTTPServer.new(4567)
server.start
