require "warehouse/json_api/json_http_client"
require 'warehouse/json_api/transforms'
require 'multi_json'

module Warehouse
  class JsonAPI
    class Projects
      attr_reader :client

      def initialize(http_client)
        @client = JsonHttpClient.new(http_client)
      end

      def create_project!(project_data)
        body = {
          name:       project_data[:name],
          client_id:  project_data[:client_id],
          source_url: project_data[:source_url]
        }

        client.post("/v1/projects", body, {
          201 => lambda do |response|
            body = MultiJson.load(response[:body])
            Transforms.rubyize(body)
          end
        })
      end

      def update_project!(project_id, project_data)
        body = project_data.slice(:name, :client_id, :source_url)

        client.put("/v1/projects/#{project_id}", body, {
          200 => lambda do |response|
            nil
          end
        })
      end

      def find_project_by_id(project_id)
        client.get("/v1/projects/#{project_id}", {}, {
          200 => lambda do |response|
            body = MultiJson.load(response[:body])
            project = Transforms.rubyize(body)
            Transforms.parse_timestamps(project)
          end,
          404 => lambda do |response|
            nil
          end
        })
      end

      def find_all_projects
        client.get("/v1/projects", {}, {
          200 => lambda do |response|
            body = MultiJson.load(response[:body])
            projects = Transforms.rubyize(body["projects"])
            projects.map { |p| Transforms.parse_timestamps(p) }
          end
        })
      end
    end
  end
end
