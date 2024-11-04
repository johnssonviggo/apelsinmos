class Request

  attr_reader :method, :resource, :version

  def initialize(request_string)
    lines = request_string.split("\n")
    first_line = lines[0]
    pp first_line
    the_first_line = first_line.split(" ")
    pp the_first_line

    if the_first_line[0] == "GET"
      @method = :get
    elsif the_first_line[0] == "POST"
      @method = :post
    end
    @resource = the_first_line[1]
    @version = the_first_line[2]
  end
end
