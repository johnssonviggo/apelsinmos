# Represents HTTP request, parsing its components such as method, resource, version, headers and params.
#
# This class is responsible for parsing an HTTP request string and extracting its various components,
# such as the HTTP method, resource path, headers, query parameters, and body. The extracted
# information is then stored in instance variables for easy access.
class Request
# @return [Symbol] The HTTP method (:get or :post)
attr_reader :method

# @return [String] The requested resource path (e.g, "/index.html")
attr_reader :resource


# @return [String] The HTTP version (e.g, "HTTP/1.1")
attr_reader :version

# @return [Hash] The HTTP headers as key-value pairs
attr_reader :headers

# @return [Hash] The query parameters from the URL
attr_reader :params


  # Parses an HTTP request string and draw out its components.
  #
  # This method processes the raw HTTP request string, extracting the HTTP method, resource path,
  # version, headers, and query parameters. It also handles the parsing of the request body, if present.
  #
  # @param request_string [String] The raw HTTP request received from the client.
  # @return [void]
  #
  # @example
  #   request = Request.new("GET /index.html HTTP/1.1\nHost: example.com\n...")
  #   request.method  # => :get
  #   request.resource  # => "/index.html"
  #   request.headers  # => { "Host" => "example.com", ... }
  #   request.params  # => { "param1" => "value1", ... }
  def initialize(request_string)
    lines = request_string.split("\n")  # Split request into lines
    first_line = lines[0]               # Extract the request line (e.g., "GET /index.html HTTP/1.1")
    the_first_line = first_line.split(" ") # Split the first line into parts

    if the_first_line[0] == "GET"
      @method = :get
    elsif the_first_line[0] == "POST"
      @method = :post
    end


    @resource = the_first_line[1]  # Extract the requested resource path
    @version = the_first_line[2]   # Extract the HTTP version
    @headers = {}                  # Initialize headers hash
    @params = {}                   # Initialize query params hash

    # Parse headers
    i = 1
    while i < lines.length
      key, value = lines[i].split(": ", 2)
      @headers[key] = value
      i += 1
    end

    # Extracts the body if it exists
    body_index = lines.index("")
    @body = body_index ? lines[(body_index + 1)..].join("\n") : nil

    # Parses the query parameters if present in the URL
    if @resource.include?("?")
      _path, params_string = @resource.split("?", 2)
      params_string2 = params_string.split("&")
      i = 0
        while i < params_string2.length
          key, value = params_string2[i].split("=",2 )
          @params[key] = value if key
          i += 1
        end
      end
    end

    # Adds POST params to the request.
    #
    # This method is used to extract parameters from the request body when handling POST requests.
    #
    # @param body [String] the raw body content from the HTTP request.
    # @return [void]
    # @example
    #   request.add_post_params("key1=value1&key2=value2")
    #   request.params  # => { "key1" => "value1", "key2" => "value2" }
    def add_post_params(body)
      post_params = body.split("&")
      i = 0
      while i < post_params.length
        key, value = post_params[i].split("=", 2)
        @params[key] = value if key
        i += 1
      end
    end
end
