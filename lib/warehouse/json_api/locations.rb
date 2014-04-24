require 'warehouse/json_api/transforms'
require 'multi_json'

module Warehouse
  class JsonAPI
    class Locations
      attr_reader :client

      def initialize(http_client)
        @client = JsonHttpClient.new(http_client)
      end

      def find_all_locations
        client.get("/v1/locations", {}, {
          200 => lambda do |response|
            body = MultiJson.load(response[:body])
            Transforms.rubyize(body["locations"]).map do |location|
              location = Transforms.parse_timestamps(location)
            end
          end
        })
      end
    end
  end
end
