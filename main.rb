require_relative "lib/request"

# x = Request.new(File.read("test/example_requests/get-index.request.txt"))

# p x

# y = Request.new(File.read("test/example_requests/get-examples.request.txt"))

# p y

a = Request.new(File.read("test/example_requests/get-examples.request.txt"))
p a.method
p a.resource
p a.version
