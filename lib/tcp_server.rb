require 'socket'
require_relative 'request'
require_relative 'router'
require 'mime-types'

# Path to the public directory for serving static files.
PUBLIC_DIR = File.expand_path("../public", __dir__)

# A simple HTTP server implementation.
class HTTPServer
    # Initializes the HTTP server with a specified port.
    #
    # @param port [Integer] The port number the server will listen on.
    def initialize(port)
        @port = port
    end

    # Starts the HTTP server, listens for incoming requests, and routes them.
    #
    # @return [void]
    def start
        server = TCPServer.new(@port)
        puts "Listening on #{@port}"

        # Initialize router and define routes.
        router = Router.new
        router.add_route(:get, "/banan") do
            File.read("views/index.html")
        end
        router.add_route(:get, "/senap") do
            "<h1>SENAP</h1>"
            "<img>src='public/img/raft.png'</img>"
        end
        router.add_route(:get, "/hejsan") do
            "<h1>HEJSAN</h1>"
        end

        # Accept and process incoming requests.
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
            matching_route = router.match_route(request)

            if matching_route
                response = Response.new(matching_route[:block].call, session)
            else
                file_path = File.join(PUBLIC_DIR, request.resource)
            if File.exist?(file_path) && File.file?(file_path)
                    response = Response.new(file_path, session, file: true)
            else
                    # 404 Not found
                    response = Response.new("Oh noes", session, status: 404)
            end
        end


            response.send

        end
    end
end

# A class representing HTTP response.
class Response

    # Initializes a new HTTP response.
    #
    # @param result [String] The response body content or file path.
    # @param session [TCPSocket] The active client session.
    # @param file [Boolean] Whether the response is serving a file.
    # @param status [Integer] The HTTP status code (default: 200).
    def initialize(result, session, file: false, status: 200)
        @session = session
        @result = result
        @status = status
        @file = file
    end

    # Sends the response to the client.
    #
    # @return [void]
    def send
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

  # Returns the status message corresponding to the HTTP status code.
  #
  # @return [String] The status message.
  def status_message
    case @status
    when 200 then "OK"
    when 404 then "Not Found"
    when 500 then "Internal Server Error"
    else "Unknown"
    end
  end
end

# Start the HTTP server on port 4567.
server = HTTPServer.new(4567)
server.start
