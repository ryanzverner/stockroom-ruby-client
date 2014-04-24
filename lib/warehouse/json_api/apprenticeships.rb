require "warehouse/json_api/json_http_client"
require 'warehouse/json_api/transforms'
require 'multi_json'

module Warehouse
  class JsonAPI
    class Apprenticeships
      attr_reader :client

      def initialize(http_client)
        @client = JsonHttpClient.new(http_client)
      end

      def find_all_apprenticeships
        client.get("/v1/apprenticeships", {}, {
          200 => lambda do |response|
            body = MultiJson.load(response[:body])

            body = Transforms.rubyize(body)

            rubyize_apprenticeships(body[:apprenticeships])
          end
        })
      end

      def find_apprenticeship_by_id(id)
        client.get("/v1/apprenticeships/#{id}", {}, {
          200 => lambda do |response|
            body = MultiJson.load(response[:body])

            body = Transforms.rubyize(body)

            rubyize_apprenticeship(body)
          end
        })
      end

      def create_apprenticeship!(data)
        body = prepare_apprenticeship(data)

        client.post("/v1/apprenticeships", body, {
          201 => lambda do |response|
            MultiJson.load(response[:body])
          end
        })
      end

      def upcoming_apprentice_graduations_grouped_by_location
        client.get("/v1/apprenticeships/graduations", {}, {
          200 => lambda do |response|
            body = MultiJson.load(response[:body])
            body = Transforms.rubyize(body)
            rubyize_upcoming_apprentice_graudations_grouped_by_location(body)
          end
        })
      end

      private

      def prepare_apprenticeship(data)
        {
          :person_id => data[:person_id],
          :skill_level => data[:skill_level],
          :start => Transforms.format_as_date(data[:start]),
          :end => Transforms.format_as_date(data[:end]),
          :mentorships => prepare_mentorships(data[:mentorships])
        }
      end

      def prepare_mentorships(mentorships)
        mentorships.map { |mentorship| prepare_mentorship(mentorship) }
      end

      def prepare_mentorship(data)
        {
          :person_id => data[:person_id],
          :start => Transforms.format_as_date(data[:start]),
          :end => Transforms.format_as_date(data[:end])
        }
      end

      def rubyize_apprenticeships(apprenticeships)
        apprenticeships.map { |a| rubyize_apprenticeship(a) }
      end

      def rubyize_apprenticeship(apprenticeship)
        apprenticeship = Transforms.parse_timestamps(apprenticeship)
        apprenticeship = Transforms.parse_time_value(apprenticeship, :start)
        apprenticeship = Transforms.parse_time_value(apprenticeship, :end)
        apprenticeship[:mentorships] = rubyize_mentorships(apprenticeship[:mentorships])
        apprenticeship
      end

      def rubyize_mentorships(mentorships)
        mentorships.map { |m| rubyize_mentorship(m) }
      end

      def rubyize_mentorship(mentorship)
        mentorship = Transforms.parse_time_value(mentorship, :start)
        mentorship = Transforms.parse_time_value(mentorship, :end)
        mentorship
      end

      def rubyize_upcoming_apprentice_graudations_grouped_by_location(locations_information)
        locations_information.map do |location_information|
          location_information.reduce(location_information) do |location_information, (key, value)|
            if key == :current_apprentices
              location_information[key] = value.map do |apprentice_information|
                Transforms.parse_time_value(apprentice_information, :graduates_at)
              end
            end

            location_information
          end
        end
      end
    end
  end
end
