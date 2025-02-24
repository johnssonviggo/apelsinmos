# Router class to handle and match HTTP routes.
class Router
  # Initializes a new Router instance.
  # @routes is an array storing route definitions.
  def initialize
    @routes = []
  end

  # Adds a new route to the router.
  #
  # @param method [Symbol] The HTTP method (e.g., :get, :post).
  # @param resource [String] The resource path (e.g., "/users").
  # @yield The block to execute when the route is matched.
  # @return [void]
  def add_route(method, resource, &block)
    @routes << {method: method, resource: resource, block: block}
  end

  # Matches an incoming request to a stored route.
  #
  # @param request [Object] The request object containing `method` and `resource`.
  # @return [Hash, nil] The matched route or nil if no match is found.
  def match_route(request)
    # require 'debug'
    # binding.break

    @routes.each do |route|
      if route[:method] == request.method && route[:resource] == request.resource
        return route
      end
    end
    return nil
  end



end
