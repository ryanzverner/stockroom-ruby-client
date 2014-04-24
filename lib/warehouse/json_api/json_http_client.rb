require 'warehouse/json_api/transforms'
require 'warehouse/errors'
require 'multi_json'

module Warehouse
  class JsonAPI
    private

    class JsonHttpClient
      attr_reader :http_client

      def initialize(http_client)
        @http_client = http_client
      end

      def get(path, query={}, responders)
        options = {
          :headers => {
            "Accept" => "application/json"
          },
          :query => query
        }

        when_status(http_client.get(path, options), responders)
      end

      def post(path, data, responders)
        when_status(
          http_client.post(path, Transforms.jsonize(data).to_json, {
            :headers => {
              "Accept"        => "application/json",
              "Content-Type"  => "application/json"
            }
          }),
          responders)
      end

      def put(path, data, responders)
        when_status(
          http_client.put(path, Transforms.jsonize(data).to_json, {
            :headers => {
              "Accept"        => "application/json",
              "Content-Type"  => "application/json"
            }
          }),
          responders)
      end

      def delete(path, responders)
        when_status(
          http_client.delete(path, {
            :headers => {
              "Accept" => "application/json",
            }
          }),
          responders)
      end

      private

      def parse_body_errors(response)
        body = MultiJson.load(response[:body])
        Transforms.rubyize_errors(body["errors"])
      end

      def when_status(response, responders)
        if responder = responders[response[:status]]
          responder.call(response)
        else
          handle_generically(response)
        end
      end

      def handle_generically(response)
        errors = begin
                   parse_body_errors(response)
                 rescue
                   []
                 end

        case response[:status]
        when 401
          raise AuthenticationError.new(errors)
        when 403
          raise AuthorizationError.new(errors)
        when 404
          raise NotFoundError.new(errors)
        when 422
          raise ValidationError.new(errors)
        else
          raise ApiError.new(response)
        end
      end
    end
  end
end
