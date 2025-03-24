# Router class to handle and match HTTP routes.
#
# This class manages the routing of incoming HTTP requests to their appropriate
# handlers. It supports adding routes with specific HTTP methods and resource paths,
# and matching incoming requests to the stored routes.
class Router
  # Stores route definitions as an array of hashes.
  # Each route includes an HTTP method, a resource path, and a block.
  #
  # @return [Array <Hash>] An array of route definitions.
  def initialize
    @routes = []
  end

  # Adds a new route to the router.
  #
  # @param method [Symbol] The HTTP method (e.g, :get, :post).
  # @param resource [String] The resource path (e.g, "/users").
  # @yieldparam request [Object] The request object passed to the block when the route is matched.
  # @return [void]
  #
  # @example
  #   router.add_route(:get, "/users/:id") do |request|
  #     # Handler logic for GET /users/:id
  #   end
  def add_route(method, resource, &block)
    regex = resource.gsub(/:\w+/, '([^\/]+)') # Replace :param with a capturing regex
    regex = /^#{regex}$/ ## Ensure the regex matches the entire string
    @routes << {method: method, resource: resource, block: block, regex: regex}
  end

  # Matches an incoming request to a stored route.
  #
  # @param request [Object] The request object containing `method` and `resource`.
  # @return [Hash, nil] Returns a hash containing the matched route's block and params if match = found,
  # or nil if no match is found.
  def match_route(request)
    @routes.each do |route|
      match = request.resource.match(route[:regex])
      if route[:method] == request.method && match = request.resource.match(route[:regex])
        params = extract_params(route[:resource], match.captures)
        return { block: route[:block], params: params }
      end
    end
    nil
  end

  private

  # Extracts parameters from the resource path and match values.
  #
  # @param resource [String] The resource path that contains parameter placeholders (e.g., "/users/:id").
  # @param values [Array<String>] The matched values from the regular expression capture groups.
  # @return [Hash] A hash of parameter names and their corresponding matched values.
  #
  # @example
  #   extract_params("/users/:id", ["123"]) # => { "id" => "123" }
  def extract_params(resource, values)
    keys = resource.scan(/:(\w+)/).flatten
    Hash[keys.zip(values)]
  end
end
