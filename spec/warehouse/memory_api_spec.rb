require 'warehouse/memory_api'
require 'warehouse/mock_api'
require 'surrogate/rspec'

describe Warehouse::MemoryAPI do
  let(:api) { described_class.new }

  it 'implements the api interface' do
    described_class.should substitute_for(Warehouse::MockAPI)
  end

  it "creates and finds a client" do
    client_id = api.create_client!({name: "test client", :client_id => "10"})
    found_client = api.find_client_by_id(client_id)
    found_client[:name].should == "test client"
    found_client[:client_id].should == "10"
  end

  it "updates a client" do
    client_id = api.create_client!({name: "test client", :client_id => "10"})
    api.update_client!(client_id, {name: "another test client"})
    found_client = api.find_client_by_id(client_id)
    found_client[:name].should == "another test client"
  end

  it "finds all clients" do
    client_id = api.create_client!({name: "test client", :client_id => "10"})
    all_clients = api.find_all_clients
    found_client = all_clients.first
    found_client[:name].should == "test client"
    found_client[:client_id].should == "10"
  end

  it "creates and finds a project" do
    project_id = api.create_project!({name: "test project", :client_id => "10"})
    found_project = api.find_project_by_id(project_id)
    found_project[:name].should == "test project"
    found_project[:client_id].should == "10"
  end

  it "updates a project" do
    project_id = api.create_project!({name: "test project", client_id: "10"})
    api.update_project!(project_id, {name: "another test project"})
    found_project = api.find_project_by_id(project_id)
    found_project[:name].should == "another test project"
  end

  it "finds all projects" do
    project_id = api.create_project!({name: "test project", :client_id => "10"})
    all_projects = api.find_all_projects
    found_project = all_projects.first
    found_project[:name].should == "test project"
    found_project[:client_id].should == "10"
  end

  it "creates and find an employment" do
    start = Date.new(2002, 4, 5)
    end_date = Date.new(2002, 4, 6)
    employment_id = api.create_employment!({:person_id => "10", :position_id => "11", :start => start, :end => end_date})
    found_employment = api.find_employment_by_id(employment_id)
    found_employment[:person_id].should == "10"
    found_employment[:position_id].should == "11"
    found_employment[:start].should == start
    found_employment[:end].should == end_date
  end

  it "updates an employment" do
    new_person_id = 11
    new_position_id = 12
    new_start_date = Date.new(2002, 4, 6)
    new_end_date = Date.new(2003, 4, 6)
    employment_id = api.create_employment!({:person_id => "10", :position_id => "11", :start => Date.new(2002, 4, 5), :end => Date.new(2002, 4, 6)})

    api.update_employment!(employment_id, {:person_id => new_person_id, :position_id => new_position_id, :start => new_start_date, :end => new_end_date})

    found_employment = api.find_employment_by_id(employment_id)
    found_employment[:person_id].should eq(new_person_id)
    found_employment[:position_id].should eq(new_position_id)
    found_employment[:start].should eq(new_start_date)
    found_employment[:end].should eq(new_end_date)
  end

  it "creates and finds a person" do
    person_id = api.create_person!({:first_name => "Kevin",
                                    :last_name => "Malone",
                                    :email => "kmalone@dundermifflin.com"})
    found_person = api.find_person_by_id(person_id)
    found_person[:first_name].should == "Kevin"
    found_person[:last_name].should == "Malone"
    found_person[:email].should == "kmalone@dundermifflin.com"
  end

  it "updates a person" do
    person_id = api.create_person!({:first_name => "Kevin",
                                    :last_name => "Malone",
                                    :email => "kmalone@dundermifflin.com"})
    api.update_person!(person_id, {:first_name => "John",
                                   :last_name => "Stockton",
                                   :email => "jstockton@dundermifflin.com"})
    found_person = api.find_person_by_id(person_id)
    found_person[:first_name].should == "John"
    found_person[:last_name].should == "Stockton"
    found_person[:email].should == "jstockton@dundermifflin.com"
  end

  it "searches for a person" do
    person_id = api.create_person!({:first_name => "Kevin",
                                    :last_name => "Malone",
                                    :email => "kmalone@dundermifflin.com"})
    found_people = api.search_people({:first_name => "Kevin",
                                      :last_name => "Malone",
                                      :email => "kmalone@dundermifflin.com"})
    found_people.size.should == 1
    found_people.first[:id].should == person_id
  end

  it "creates an engagement" do
    start_date =  Date.new(2014, 01, 13)
    end_date =  Date.new(2014, 01, 19)
    engagement_id = api.create_engagement!({:project_id => "abc",
                                            :employment_id => "employment_id",
                                            :confidence_percentage => 65,
                                            :start => start_date,
                                            :end => end_date})
    found_engagement = api.find_engagement_by_id(engagement_id)
    found_engagement[:project_id].should == "abc"
    found_engagement[:employment_id].should == "employment_id"
    found_engagement[:confidence_percentage].should == 65
    found_engagement[:start].should == start_date
    found_engagement[:end].should == end_date
  end

  it "updates an engagement" do
    start_date =  Date.new(2014, 01, 13)
    end_date =  Date.new(2014, 01, 19)
    engagement_id = api.create_engagement!({:project_id => "abc",
                                            :employment_id => "employment_id",
                                            :confidence_percentage => 15,
                                            :start => start_date,
                                            :end => end_date})
    api.update_engagement!(engagement_id, {:project_id => "ab",
                                           :employment_id => "mployment_id",
                                           :confidence_percentage => 25,
                                           :start => end_date,
                                           :end => start_date})
    found_engagement = api.find_engagement_by_id(engagement_id)
    found_engagement[:project_id].should == "ab"
    found_engagement[:employment_id].should == "mployment_id"
    found_engagement[:confidence_percentage].should == 25
    found_engagement[:start].should == end_date
    found_engagement[:end].should == start_date
  end

  it "finds all apprenticeships" do
    start_date =  Date.new(2014, 01, 13)
    end_date =  Date.new(2014, 01, 19)
    mentee_id = api.create_person!({:first_name => "Kevin",
                                    :last_name => "Malone",
                                    :email => "kmalone@dundermifflin.com"})
    mentor_id = api.create_person!({:first_name => "Bob",
                                    :last_name => "Saget",
                                    :email => "bobsaget@dundermifflin.com"})
    apprenticeship_attrs = {
      :person_id => mentee_id,
      :skill_level => "resident",
      :start => start_date,
      :end => end_date,
      :mentorships => [{
        :person_id => mentor_id,
        :start => start_date,
        :end => end_date
      }]
    }

    2.times { api.create_apprenticeship!(apprenticeship_attrs) }
    found_apprenticeships = api.find_all_apprenticeships
    found_apprenticeships.should == [apprenticeship_attrs.merge(:id => "1"), apprenticeship_attrs.merge(:id => "2")]
  end

  it "creates an apprenticeship and finds an apprenticeship by id" do
    start_date =  Date.new(2014, 01, 13)
    end_date =  Date.new(2014, 01, 19)
    mentee_id = api.create_person!({:first_name => "Kevin",
                                    :last_name => "Malone",
                                    :email => "kmalone@dundermifflin.com"})
    mentor_id = api.create_person!({:first_name => "Bob",
                                    :last_name => "Saget",
                                    :email => "bobsaget@dundermifflin.com"})
    apprenticeship_attrs = {
      :person_id => mentee_id,
      :skill_level => "resident",
      :start => start_date,
      :end => end_date,
      :mentorships => [{
        :person_id => mentor_id,
        :start => start_date,
        :end => end_date
      }]
    }
    apprenticeship_id = api.create_apprenticeship!(apprenticeship_attrs)
    found_apprenticeship = api.find_apprenticeship_by_id(apprenticeship_id)
    found_apprenticeship.should == apprenticeship_attrs.merge(:id => "1")
  end

  it "creates a director and find by id" do
    start_date = Date.new(2014, 01, 13)
    director_attributes = {
      :person_id => 12,
      :project_id => 13,
      :start => start_date
    }

    director_id = api.create_director_engagement!(director_attributes)
    found_director = api.find_director_engagement_by_id(director_id)
    found_director.should == director_attributes.merge(:id => "1")
  end

  it "updates a director" do
    start_date = Date.new(2014, 01, 13)
    director_attributes = {
      :person_id => 12,
      :project_id => 13,
      :start => start_date
    }

    director_id = api.create_director_engagement!(director_attributes)
    api.update_director_engagement!(director_id, director_attributes.merge(:end_date => Date.new(2014, 01, 14)))
    found_director = api.find_director_engagement_by_id(director_id)
    found_director.should == director_attributes.merge(:end_date => Date.new(2014, 01, 14), :id => "1")
  end

  it "creates a location" do
    location_id = api.create_location!({name: "Chicago"})
    location = api.find_all_locations.first

    expect(location[:name]).to eq "Chicago"
    expect(location[:id]).to eq location_id
  end

  it "finds employments for a location id" do
    belongs_to_location = api.create_employment!({})
    does_not_belong_to_location = api.create_employment!({})
    location_membership_attributes = {
      :location_id => 1,
      :employment_id => belongs_to_location
    }
    location_membership_id = api.create_location_membership!(location_membership_attributes)
    employments = api.find_all_employments(location_id: 1)
    employment_ids = employments.map { |e| e[:id] }

    expect(employment_ids).not_to include(does_not_belong_to_location)
    expect(employment_ids).to include(belongs_to_location)
  end

  it "finds employments within a date range" do
    start_date = "2017-01-01"
    end_date = "2017-06-01"
    ends_before_start_date = api.create_employment!({start: Date.new(2015,1,1), end: Date.new(2016,12,31)})
    starts_after_end_date = api.create_employment!({start: Date.new(2017,7,1), end: Date.new(2017,12,31)})
    within_date_range = api.create_employment!({start: Date.new(2015,7,1), end: Date.new(2017,12,31)})
    employments = api.find_all_employments(start_date: start_date, end_date: end_date)
    employment_ids = employments.map { |e| e[:id] }

    expect(employment_ids).not_to include(ends_before_start_date)
    expect(employment_ids).not_to include(starts_after_end_date)
    expect(employment_ids).to include(within_date_range)
  end
end
