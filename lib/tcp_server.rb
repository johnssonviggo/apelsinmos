require 'socket'
require_relative 'request'
require_relative 'router'
require 'mime-types'
require 'json'

# Path to the public directory for serving static files.
PUBLIC_DIR = File.expand_path("../public", __dir__)

# A simple HTTP server implementation.
#
# This class sets up a basic HTTP server that listens for incoming requests,
# processes them, and sends appropriate responses back to the client.
class HTTPServer
    # Initializes the HTTP server with a specified port.
    #
    # @param port [Integer] The port number the server will listen on.
    # @return [void]
    def initialize(port)
        @port = port
    end



    # Starts the HTTP server, listens for incoming requests, and routes them.
    #
    # The server listens on the specified port, processes incoming HTTP requests,
    # and matches them against the defined routes. If a match is found, the corresponding
    # block is executed to generate the response. Static files can also be served.
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
            "<h1>SENAP</h1>
            <img src='/img/raft.png'/>"
        end
        router.add_route(:get, "/hejsan") do
            "<h1>HEJSAN</h1>
            <form action='/banan' method='post'>
                <input type='text' name='username'>
                <button type='submit'>Skicka</button>
            </form>"

        end
        router.add_route(:get, "/") do
            "<h1>Startsida</h1>
            <a href='/banan'>
                <button type'button'>Knapp 1</button>
            </a>

            <a href='/senap'>
                <button type'button'>Knapp 2</button>
            </a>
            "
        end


        # router.add_route(:post, "/banan") do |params|

        #     puts "IN POST /banan"

        #     require 'debug'
        #     binding.break

        #     puts "hello #{params['username']}"

        #     redirect "/users/#{'username'}"
        # end

        router.add_route(:get, "/users/:id") do |session, params|
            Response.json(session, { id: params["id"], name: "Användare #{params['id']}" })
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

            p "DATA:"
            pp data
            p "---------------------------------"

            request = Request.new(data)

            if request.method == :post
              body = session.gets(request.headers["Content-Length"].to_i)
              request.add_post_params(body)
            end

            matching_route = router.match_route(request)


            if matching_route
                response = Response.new(matching_route[:block].call(session, request.params), session)
            else
                file_path = File.join(PUBLIC_DIR, request.resource)
            if File.exist?(file_path) && File.file?(file_path)
                    response = Response.new(file_path, session, file: true)
            else
                    # 404 Not found
                    response = Response.new("Oh noes, 404 Not Found", session, status: 404)
            end

        end

            response.send

        end
    end
end

# A class representing HTTP response.
#
# Responsible for sending HTTP responses to the client, including setting the status, content type, and content.
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
    # Depending on whether the response is serving a file or plain content, this method sets the appropriate headers
    # and sends the response body to the client.
    #
    # @return [void]
    def send
        begin
        if @file
            content_type = MIME::Types.type_for(@result).first.to_s || "application/octet-stream"
            content = File.binread(@result)
        else
          content_type = "text/html"
          content = @result || ""  # Sets content to empty string if @result is nil
        end


        @session.print "HTTP/1.1 #{@status}\r\n"
        @session.print "Content-Type: #{content_type}\r\n"
        @session.print "Content-Length: #{content.bytesize}\r\n"
        @session.print "\r\n"
        @session.print content
    rescue Errno::EPIPE
        puts "Client disconnected before response was sent."
    ensure
        @session.close
        end
    end

    # Sends a JSON response.
    #
    # @param session [TCPSocket] The active client session.
    # @param data [Hash] The data to send as a JSON response.
    # @param status [Integer] The HTTP status code (default: 200).
    # @return [void]
    def self.json(session, data, status: 200)
        json_content = JSON.generate(data)
        session.print "HTTP/1.1 #{status}\r\n"
        session.print "Content-Type: application/json\r\n"
        session.print "Content-Length: #{json_content.bytesize}\r\n"
        session.print "\r\n"
        session.print json_content
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
