require "warehouse/json_api/json_http_client"
require 'warehouse/json_api/transforms'
require 'multi_json'

module Warehouse
  class JsonAPI
    class Clients
      attr_reader :client

      def initialize(http_client)
        @client = JsonHttpClient.new(http_client)
      end

      def create_client!(client_data)
        body = {
          :name => client_data[:name]
        }

        client.post("/v1/clients", body, {
          201 => lambda do |response|
            MultiJson.load(response[:body])
          end
        })
      end

      def update_client!(client_id, client_data)
        body = client_data.slice(:name)

        client.put("/v1/clients/#{client_id}", body, {
          200 => lambda do |response|
            nil
          end
        })
      end

      def find_all_clients
        client.get("/v1/clients", {}, {
          200 => lambda do |response|
            body = MultiJson.load(response[:body])
            body["clients"].map { |c| rubyize_client(c) }
          end
        })
      end

      def find_client_by_id(client_id)
        client.get("/v1/clients/#{client_id}", {}, {
          200 => lambda do |response|
            body = MultiJson.load(response[:body])
            rubyize_client(body)
          end
        })
      end

      private

      def rubyize_client(client)
        client = Transforms.rubyize(client)
        Transforms.parse_timestamps(client)
      end
    end
  end
end
