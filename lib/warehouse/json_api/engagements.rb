require "warehouse/json_api/json_http_client"
require 'warehouse/json_api/transforms'
require 'multi_json'

module Warehouse
  class JsonAPI
    class Engagements
      attr_reader :client

      def initialize(http_client)
        @client = JsonHttpClient.new(http_client)
      end

      def create_engagement!(options)
        body = {
          :start => Transforms.format_as_date(options[:start]),
          :end => Transforms.format_as_date(options[:end]),
          :confidence_percentage => options[:confidence_percentage],
          :project_id => options[:project_id],
          :employment_id => options[:employment_id]
        }

        client.post("/v1/engagements", body, {
          201 => lambda do |response|
            MultiJson.load(response[:body])
          end
        })
      end

      def update_engagement!(engagement_id, options)
        body = options.slice(:employment_id, :project_id, :confidence_percentage)
        body[:start] = Transforms.format_as_date(options[:start]) if options.has_key?(:start)
        body[:end] = Transforms.format_as_date(options[:end]) if options.has_key?(:end)

        client.put("/v1/engagements/#{engagement_id}", body, {
          200 => lambda do |response|
            nil
          end
        })
      end

      def delete_engagement!(engagement_id)
        client.delete("/v1/engagements/#{engagement_id}", {
          200 => lambda { |_| nil }
        })
      end

      def find_all_engagements(options)
        if start = options[:start]
          options[:start] = Transforms.format_as_date(start)
        end
        if _end = options[:end]
          options[:end] = Transforms.format_as_date(_end)
        end

        client.get("/v1/engagements", Transforms.kebabize(options), {
          200 => lambda do |response|
            body = MultiJson.load(response[:body])
            body["engagements"].map do |json_engagement|
              rubyize_engagement(json_engagement)
            end
          end
        })
      end

      def find_engagement_by_id(id)
        client.get("/v1/engagements/#{id}", {}, {
          200 => lambda do |response|
            body = MultiJson.load(response[:body])
            rubyize_engagement(body)
          end,
          404 => lambda do |response|
            nil
          end
        })
      end

      private

      def rubyize_engagement(engagement)
        engagement = Transforms.rubyize(engagement)
        engagement = Transforms.parse_timestamps(engagement)
        engagement = Transforms.parse_date_value(engagement, :start)
        engagement = Transforms.parse_date_value(engagement, :end)
        engagement[:person] = Transforms.parse_timestamps(engagement[:person]) if engagement[:person]
        engagement[:project] = Transforms.parse_timestamps(engagement[:project]) if engagement[:person]
        engagement
      end
    end
  end
end
