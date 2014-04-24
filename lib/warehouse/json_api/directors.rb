require "warehouse/json_api/json_http_client"
require 'warehouse/json_api/transforms'
require 'multi_json'

module Warehouse
  class JsonAPI
    class Directors
      attr_reader :client

      def initialize(http_client)
        @client = JsonHttpClient.new(http_client)
      end

      def create_director_engagement!(director_data)
        body = {
          :person_id => director_data[:person_id],
          :project_id => director_data[:project_id],
          :start => Transforms.format_as_date(director_data[:start]),
          :end => Transforms.format_as_date(director_data[:end])
        }

        client.post("/v1/director-engagements", body, {
          201 => lambda do |response|
            MultiJson.load(response[:body])
          end
        })
      end

      def update_director_engagement!(director_engagement_id, director_data)
        body = director_data.slice(:person_id, :project_id)
        body[:start] = Transforms.format_as_date(director_data[:start]) if director_data.has_key?(:start)
        body[:end] = Transforms.format_as_date(director_data[:end]) if director_data.has_key?(:end)

        client.put("/v1/director-engagements/#{director_engagement_id}", body, {
          200 => lambda do |response|
            nil
          end
        })
      end

      def find_director_engagement_by_id(director_engagement_id)
        client.get("/v1/director-engagements/#{director_engagement_id}", {}, {
          200 => lambda do |response|
            body = MultiJson.load(response[:body])
            rubyize_engagement(body)
          end
        })
      end

      def find_current_directors
        client.get("/v1/directors/current", {}, {
          200 => lambda do |response|
            body = MultiJson.load(response[:body])
            body["directors"].map do |director|
              director = Transforms.rubyize(director)
              Transforms.parse_timestamps(director)
            end
          end
        })
      end

      def find_director_engagements_by_person_id(person_id)
        client.get("/v1/directors/#{person_id}/director-engagements", {}, {
          200 => lambda do |response|
            body = MultiJson.load(response[:body])
            body["directorEngagements"].map do |engagement|
              rubyize_engagement(engagement)
            end
          end
        })
      end

      private

      def rubyize_engagement(engagement)
        engagement = Transforms.rubyize(engagement)
        engagement = Transforms.parse_timestamps(engagement)
        engagement = Transforms.parse_date_value(engagement, :start)
        Transforms.parse_date_value(engagement, :end)
      end
    end
  end
end

