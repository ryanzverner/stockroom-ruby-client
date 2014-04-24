require 'warehouse/json_api/transforms'
require 'multi_json'

module Warehouse
  class JsonAPI
    class People
      attr_reader :client

      def initialize(http_client)
        @client = JsonHttpClient.new(http_client)
      end

      def create_person!(options)
        body = {
          :first_name => options[:first_name],
          :last_name => options[:last_name],
          :email => options[:email]
        }

        client.post("/v1/people", body, {
          201 => lambda do |response|
            MultiJson.load(response[:body])
          end
        })
      end

      def update_person!(person_id, options)
        body = options.slice(:first_name, :last_name, :email)

        client.put("/v1/people/#{person_id}", body, {
          200 => lambda do |response|
            nil
          end
        })
      end

      def find_person_by_id(person_id)
        client.get("/v1/people/#{person_id}", {}, {
          200 => lambda do |response|
            body = MultiJson.load(response[:body])
            person = Transforms.rubyize(body)
            Transforms.parse_timestamps(person)
          end
        })
      end

      def search_people(criteria)
        client.get("/v1/people/search", Transforms.kebabize(criteria), {
          200 => lambda do |response|
            results = MultiJson.load(response[:body])
            results = results['people'].map do |person|
              person = Transforms.rubyize(person)
              Transforms.parse_timestamps(person)
            end
          end
        })
      end
    end
  end
end
