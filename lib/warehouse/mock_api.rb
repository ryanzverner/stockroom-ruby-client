require 'surrogate'

module Warehouse
  class MockAPI
    Surrogate.endow self

    define(:create_client!) do |client_data|
    end

    define(:update_client!) do |client_id, client_data|
    end

    define(:find_all_clients) do
    end

    define(:find_client_by_id) do |client_id|
    end

    define(:create_project!) do |project_data|
    end

    define(:update_project!) do |project_id, project_data|
    end

    define(:find_project_by_id) do |project_id|
    end

    define(:find_all_projects) do
    end

    define(:create_employment!) do |employment_data|
    end

    define(:update_employment!) do |employment_id, employment_data|
    end

    define(:find_employment_by_id) do |employment_id|
    end

    define(:find_all_employments) do |employment_options={}|
    end

    define(:create_person!) do |person_data|
    end

    define(:update_person!) do |person_id, person_data|
    end

    define(:find_person_by_id) do |person_id|
    end

    define(:search_people) do |criteria|
    end

    define(:create_engagement!) do |options|
      @on_create_engagement.call(options) if @on_create_engagement
    end

    def on_create_engagement!(&block)
      @on_create_engagement = block
    end

    define(:find_engagement_by_id) do |engagement_id|
    end

    define(:update_engagement!) do |engagement_id, options|
    end

    define(:delete_engagement!) do |engagement_id|
    end

    define(:find_all_engagements) do |options|
    end

    define(:find_all_apprenticeships) do
    end

    define(:upcoming_apprentice_graduations_grouped_by_location) do
    end

    define(:find_apprenticeship_by_id) do |apprenticeship_id|
    end

    define(:create_apprenticeship!) do |apprenticeship_data|
    end

    define(:find_director_engagement_by_id) do |director_id|
    end

    define(:create_director_engagement!) do |director_data|
    end

    define(:update_director_engagement!) do |director_id, director_data|
    end

    define(:find_current_directors) do
    end

    define(:find_director_engagements_by_person_id) do |person_id|
    end

    define (:find_all_locations) do
    end

    define (:create_location!) do |location_data|
    end

    define (:create_location_membership!) do |location_membership_data|
    end
  end
end
