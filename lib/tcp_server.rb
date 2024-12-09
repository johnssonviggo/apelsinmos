require 'socket'
require_relative 'request'
require_relative 'router'

class HTTPServer

    def initialize(port)
        @port = port
    end

    def start
        server = TCPServer.new(@port)
        puts "Listening on #{@port}"
        router = Router.new
        router.add_route(:get, "/banan") do
            "<h1>BANAN</h1>"
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
            pp request
            result = router.match_route(request)
            if result
              status = 200
              html = "<h1>Hej, World!</h1>"
            else
              status = 404
              html = "<h1>No found</h1>"
            end

            session.print "HTTP/1.1 #{status}\r\n"
            session.print "Content-Type: text/html\r\n"
            session.print "\r\n"
            session.print html
            session.close
        end
    end
end

server = HTTPServer.new(4567)
server.start
