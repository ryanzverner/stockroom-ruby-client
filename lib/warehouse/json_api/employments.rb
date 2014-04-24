require "warehouse/json_api/json_http_client"
require 'warehouse/json_api/transforms'
require 'multi_json'

module Warehouse
  class JsonAPI
    class Employments
      attr_reader :client

      def initialize(http_client)
        @client = JsonHttpClient.new(http_client)
      end

      def create_employment!(options)
        body = {
          :start     => Transforms.format_as_date(options[:start]),
          :end       => Transforms.format_as_date(options[:end]),
          :person_id => options[:person_id]
        }

        body[:position_name] = options[:position_name] if options[:position_name]
        body[:position_id] = options[:position_id] if options[:position_id]

        client.post("/v1/employments", body, {
          201 => lambda do |response|
            MultiJson.load(response[:body])
          end
        })
      end

      def update_employment!(employment_id, options)
        body = options.slice(:position_id, :person_id)
        body[:start] = Transforms.format_as_date(options[:start]) if options.has_key?(:start)
        body[:end] = Transforms.format_as_date(options[:end]) if options.has_key?(:end)

        client.put("/v1/employments/#{employment_id}", body, {
          200 => lambda do |response|
            nil
          end
        })
      end

      def find_employment_by_id(employment_id)
        client.get("/v1/employments/#{employment_id}", {}, {
          200 => lambda do |response|
            body = MultiJson.load(response[:body])
            employment = Transforms.rubyize(body)
            employment = Transforms.parse_timestamps(employment)
            employment = Transforms.parse_time_value(employment, :start)
            employment = Transforms.parse_time_value(employment, :end)
            employment = Transforms.update_in(employment, :person) do |person|
              Transforms.parse_timestamps(person)
            end
            employment = Transforms.update_in(employment, :position) do |position|
              Transforms.parse_timestamps(position)
            end
          end,
          404 => lambda do |response|
            nil
          end
        })
      end

      def find_all_employments(options)
        query = {}
        if options[:location_id]
          query[:"location-id"] = options[:location_id]
        end
        if options[:start_date] && options[:end_date]
          query[:"start-date"] = options[:start_date]
          query[:"end-date"] = options[:end_date]
        end
        client.get("/v1/employments", query, {
          200 => lambda do |response|
            body = MultiJson.load(response[:body])
            Transforms.rubyize(body["employments"]).map do |employment|
              employment = Transforms.parse_timestamps(employment)
              employment = Transforms.parse_time_value(employment, :start)
              employment = Transforms.parse_time_value(employment, :end)
              employment = Transforms.update_in(employment, :person) do |person|
                Transforms.parse_timestamps(person)
              end
              employment = Transforms.update_in(employment, :position) do |position|
                Transforms.parse_timestamps(position)
              end
            end
          end
        })
      end
    end
  end
end
