class Router

  def initialize
    @routes = []
  end

  def add_route(method, resource, &block)
    @routes << {method: method, resource: resource, block: block}
  end

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
