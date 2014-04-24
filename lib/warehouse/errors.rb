module Warehouse
  class NotFoundError < StandardError
  end

  class AuthenticationError < StandardError
    attr_reader :errors
    def initialize(errors)
      @errors = errors
    end
  end

  class AuthorizationError < StandardError
    attr_reader :errors
    def initialize(errors)
      @errors = errors
    end
  end

  class ApiError < StandardError
    attr_reader :response
    def initialize(response)
      @response = response
    end
  end

  class ValidationError < StandardError
    attr_reader :errors
    def initialize(errors)
      @errors = errors
    end
  end
end
