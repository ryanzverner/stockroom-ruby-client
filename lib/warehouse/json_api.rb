require 'warehouse/json_api/transforms'
require 'warehouse/json_api/apprenticeships'
require 'warehouse/json_api/clients'
require 'warehouse/json_api/directors'
require 'warehouse/json_api/employments'
require 'warehouse/json_api/engagements'
require 'warehouse/json_api/people'
require 'warehouse/json_api/projects'
require 'warehouse/json_api/locations'

module Warehouse
  class JsonAPI
    def initialize(http_client)
      @http_client = http_client
    end

    def find_all_apprenticeships
      apprenticeships_api.find_all_apprenticeships
    end

    def find_apprenticeship_by_id(id)
      apprenticeships_api.find_apprenticeship_by_id(id)
    end

    def create_apprenticeship!(data)
      apprenticeships_api.create_apprenticeship!(data)
    end

    def upcoming_apprentice_graduations_grouped_by_location
      apprenticeships_api.upcoming_apprentice_graduations_grouped_by_location
    end

    def find_all_clients
      clients_api.find_all_clients
    end

    def find_client_by_id(id)
      clients_api.find_client_by_id(id)
    end

    def create_client!(data)
      clients_api.create_client!(data)
    end

    def update_client!(client_id, data)
      clients_api.update_client!(client_id, data)
    end

    def find_all_employments(options={})
      employments_api.find_all_employments(options)
    end

    def find_employment_by_id(id)
      employments_api.find_employment_by_id(id)
    end

    def create_employment!(data)
      employments_api.create_employment!(data)
    end

    def update_employment!(id, data)
      employments_api.update_employment!(id, data)
    end

    def find_all_engagements(options)
      engagements_api.find_all_engagements(options)
    end

    def find_engagement_by_id(id)
      engagements_api.find_engagement_by_id(id)
    end

    def create_engagement!(data)
      engagements_api.create_engagement!(data)
    end

    def update_engagement!(id, data)
      engagements_api.update_engagement!(id, data)
    end

    def delete_engagement!(id)
      engagements_api.delete_engagement!(id)
    end

    def find_person_by_id(id)
      people_api.find_person_by_id(id)
    end

    def create_person!(data)
      people_api.create_person!(data)
    end

    def update_person!(person_id, data)
      people_api.update_person!(person_id, data)
    end

    def search_people(criteria)
      people_api.search_people(criteria)
    end

    def find_all_projects
      projects_api.find_all_projects
    end

    def find_project_by_id(id)
      projects_api.find_project_by_id(id)
    end

    def create_project!(data)
      projects_api.create_project!(data)
    end

    def update_project!(project_id, data)
      projects_api.update_project!(project_id, data)
    end

    def create_director_engagement!(director_data)
      directors_api.create_director_engagement!(director_data)
    end

    def update_director_engagement!(director_engagement_id, director_data)
      directors_api.update_director_engagement!(director_engagement_id, director_data)
    end

    def find_director_engagement_by_id(director_engagement_id)
      directors_api.find_director_engagement_by_id(director_engagement_id)
    end

    def find_current_directors
      directors_api.find_current_directors
    end

    def find_director_engagements_by_person_id(person_id)
      directors_api.find_director_engagements_by_person_id(person_id)
    end

    def find_all_locations
      locations_api.find_all_locations
    end

    def create_location!(location_data)
      raise NotImplementedError
    end

    def create_location_membership!(location_membership_data)
      raise NotImplementedError
    end

    private

    def apprenticeships_api
      @apprenticeships_api ||= Apprenticeships.new(@http_client)
    end

    def clients_api
      @clients_api ||= Clients.new(@http_client)
    end

    def employments_api
      @employments_api ||= Employments.new(@http_client)
    end

    def engagements_api
      @engagements_api ||= Engagements.new(@http_client)
    end

    def people_api
      @people_api ||= People.new(@http_client)
    end

    def projects_api
      @projects_api ||= Projects.new(@http_client)
    end

    def directors_api
      @directors_api ||= Directors.new(@http_client)
    end

    def locations_api
      @locations_api ||= Locations.new(@http_client)
    end
  end
end
