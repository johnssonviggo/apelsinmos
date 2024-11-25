class Request

  attr_reader :method, :resource, :version, :headers, :params

  def initialize(request_string)
    lines = request_string.split("\n")
    first_line = lines[0]
    the_first_line = first_line.split(" ")

    if the_first_line[0] == "GET"
      @method = :get
    elsif the_first_line[0] == "POST"
      @method = :post
    end
    @resource = the_first_line[1]
    @version = the_first_line[2]
    @headers = {}
    @params = {}

    i = 1
    while i < lines.length
      key, value = lines[i].split(": ")
      @headers[key] = value
      i += 1
    end

    if @resource.include?("?")
      _path, params_string = @resource.split("?")
      params_string2 = params_string.split("&")
      i = 0
        while i < params_string2.length
          key, value = params_string2[i].split("=")
          @params[key] = value
          i += 1
        end
      # else
        # post_param = @resource.split("&")
        # p post_param
    end

  end
end
