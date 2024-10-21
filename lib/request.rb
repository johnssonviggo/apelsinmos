class Request

  attr_reader :method, :resource

  def initialize(request_string)
    lines = request_string.split("\n")
    first_line = lines[0]
    the_first_line = first_line.split("\n")
    pp the_first_line
    @method = :get
    @resource = "/"
  end
end
