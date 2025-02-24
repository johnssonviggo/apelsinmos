class Request
# @return [Symbol] The HTTP method (:get or :post)
attr_reader :method

# @return [String] The requested resource path (e.g., "/index.html")
attr_reader :resource


# @return [String] The HTTP version (e.g., "HTTP/1.1")
attr_reader :version

# @return [Hash] The HTTP headers as key-value pairs
attr_reader :headers

# @return [Hash] The query parameters from the URL
attr_reader :params


  # Parses an HTTP request string and draw out its components.
  #
  # @param request_string [String] The raw HTTP request received from the client.
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
      key, value = lines[i].split(": ") # Split header line into key-value pair
      @headers[key] = value
      i += 1
    end

     # Parse query parameters from the URL
    if @resource.include?("?")
      _path, params_string = @resource.split("?")  # Separate path from query string
      params_string2 = params_string.split("&")
      i = 0
        while i < params_string2.length
          key, value = params_string2[i].split("=") # Split each query param into key-value pair
          @params[key] = value
          i += 1
        end
      # else
        # post_param = @resource.split("&")
        # p post_param

  end
end
