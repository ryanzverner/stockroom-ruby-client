module Warehouse
  class MemoryAPI

    def initialize(seeds={})
      @db = {}
      seeds.each do |table, rows|
        rows.each do |row|
          insert(table, row)
        end
      end
    end

    def create_client!(data)
      insert(:clients, data)
    end

    def update_client!(client_id, data)
      update(:clients, client_id, data)
      nil
    end

    def find_client_by_id(client_id)
      find_by_id(:clients, client_id)
    end

    def find_all_clients
      all_rows_for_table(:clients)
    end

    def create_project!(data)
      insert(:projects, data)
    end

    def update_project!(project_id, data)
      update(:projects, project_id, data)
    end

    def find_project_by_id(project_id)
      find_by_id(:projects, project_id)
    end

    def find_all_projects
      all_rows_for_table(:projects)
    end

    def create_employment!(employment_data)
      insert(:employment, employment_data)
    end

    def update_employment!(employment_id, data)
      update(:employment, employment_id, data)
      nil
    end

    def find_employment_by_id(employment_id)
      find_by_id(:employment, employment_id)
    end

    def find_all_employments(options={})
      employments = all_rows_for_table(:employment)
      if options[:location_id]
        employments = filter_employments_by_location(employments, options[:location_id])
      end
      if options[:start_date] && options[:end_date]
        employments = filter_employments_by_date_range(employments, Date.parse(options[:start_date]), Date.parse(options[:end_date]))
      end
      employments
    end

    def create_person!(data)
      insert(:people, data)
    end

    def update_person!(person_id, data)
      update(:people, person_id, data)
    end

    def find_person_by_id(person_id)
      find_by_id(:people, person_id)
    end

    def search_people(criteria)
      where(:people, criteria)
    end

    def create_engagement!(data)
      insert(:engagement, data)
    end

    def find_engagement_by_id(id)
      find_by_id(:engagement, id)
    end

    def update_engagement!(id, data)
      update(:engagement, id, data)
      nil
    end

    def delete_engagement!(id)
      raise NotImplementedError
    end

    def find_all_engagements(options)
      raise NotImplementedError
    end

    def find_all_apprenticeships
      all_rows_for_table(:apprenticeships)
    end

    def upcoming_apprentice_graduations_grouped_by_location
      raise NotImplementedError
    end

    def find_apprenticeship_by_id(apprenticeship_id)
      find_by_id(:apprenticeships, apprenticeship_id)
    end

    def create_apprenticeship!(apprenticeship_data)
      insert(:apprenticeships, apprenticeship_data)
    end

    def find_director_engagement_by_id(director_id)
      find_by_id(:director_engagements, director_id)
    end

    def create_director_engagement!(director_data)
      insert(:director_engagements, director_data)
    end

    def update_director_engagement!(director_id, director_data)
      update(:director_engagements, director_id, director_data)
      nil
    end

    def find_current_directors
      raise NotImplementedError
    end

    def find_director_engagements_by_person_id(person_id)
      raise NotImplementedError
    end

    def find_all_locations
      all_rows_for_table(:locations)
    end

    def create_location!(location_data)
      insert(:locations, location_data)
    end

    def create_location_membership!(location_membership_data)
      insert(:location_memberships, location_membership_data)
    end

    private

    attr_reader :db

    def find_by_id(table, id)
      get_table_db(table)[id.to_s]
    end

    def all_rows_for_table(table)
      get_table_db(table).values
    end

    def insert(table, row)
      table_db = get_table_db(table)
      new_id = (row[:id] || (table_db.count + 1)).to_s
      table_db.merge!(new_id => row.merge(:id => new_id))
      new_id
    end

    def update(table, id, data)
      table_db = get_table_db(table)
      table_db.merge!(id => data.merge(:id => id))
    end

    def where(table, criteria)
      table_db = get_table_db(table)
      table_db.select do |_, row|
        criteria.all? do |attr, val|
          row[attr] == val
        end
      end.values
    end

    def get_table_db(table)
      db[table] ||= {}
      db[table]
    end

    def filter_employments_by_location(employments, location_id)
      location_memberships = where(:location_memberships, {location_id: location_id})
      location_memberships.map do |location_membership|
        find_by_id(:employment, location_membership[:employment_id])
      end
    end

    def filter_employments_by_date_range(employments, start_date, end_date)
      employments.select do |employment|
        employment[:start] < end_date && employment[:end] > start_date
      end
    end
  end
end
