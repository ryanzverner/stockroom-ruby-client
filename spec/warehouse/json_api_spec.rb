require 'active_support/dependencies/autoload'
require 'active_support/core_ext/numeric'
require 'surrogate/rspec'

require 'warehouse/json_api'
require 'warehouse/mock_api'
require 'warehouse/mock_http_client'
require 'spec_helper'

require 'json'

describe Warehouse::JsonAPI do

  let(:now) { Time.parse(Time.now.utc.to_s) }
  let(:ten_days_ago) { 10.days.ago(now) }
  let(:five_days_ago) { 15.days.ago(now) }
  let(:four_days_ago) { 4.days.ago(now) }
  let(:two_days_ago) { 2.days.ago(now) }
  let(:one_day_from_now) { 1.days.from_now(now) }
  let(:one_year_from_now) { 365.days.from_now(now) }

  def format_as_date(date)
    date.strftime("%Y-%m-%d")
  end

  let(:client) { Warehouse::MockHttpClient.new }
  let(:api) { Warehouse::JsonAPI.new(client) }

  it "implements the api interface" do
    described_class.should substitute_for(Warehouse::MockAPI)
  end

  context "projects" do
    it "makes an authorized request to get projects" do
      client.will_get({
        :status => 200,
        :body => {
          "projects" => [
            {
              "id"        => 10,
              "name"      => 'project name',
              "createdAt" => now,
              "updatedAt" => one_day_from_now
            },
            {
              "id"        => 11,
              "name"      => 'project nam1',
              "createdAt" => ten_days_ago,
              "updatedAt" => one_day_from_now
            }
          ]
        }.to_json
      })

      api.find_all_projects.should == [
        {
          :id         => 10,
          :name       => 'project name',
          :created_at => now,
          :updated_at => one_day_from_now
        },
        {
          :id         => 11,
          :name       => 'project nam1',
          :created_at => ten_days_ago,
          :updated_at => one_day_from_now
        }
      ]

      client.was told_to(:get).with("/v1/projects", {:headers => {'Accept' => 'application/json'}, :query => {}})
    end

    it "makes a request to find a project by id" do
      client.will_get({
        :status => 200,
        :body => {
          "id"        => 10,
          "name"      => 'project name',
          "createdAt" => now,
          "updatedAt" => one_day_from_now
        }.to_json
      })

      api.find_project_by_id(10).should == {
        :id         => 10,
        :name       => 'project name',
        :created_at => now,
        :updated_at => one_day_from_now
      }

      client.was told_to(:get).with("/v1/projects/10", {:headers => {'Accept' => 'application/json'}, :query => {}})
    end

    it 'returns nil when the response is 404' do
      client.will_get({
        :status => 404,
        :body => ''
      })

      api.find_project_by_id(10).should be_nil
    end

    it "creates a new project" do
      client.will_post(
        :status => 201,
        :body => {project_id: 42}.to_json)

      api.create_project!(name: "Test", client_id: 100, source_url: "http://wat.bro/dawg/").should == {project_id: 42}

      client.was told_to(:post).with("/v1/projects",
        {:name => "Test", :clientId => 100, :sourceUrl => "http://wat.bro/dawg/"}.to_json,
        {:headers => {'Accept' => 'application/json', 'Content-Type' => 'application/json'}})
    end

    it "updates an existing project" do
      client.will_put(
        :status => 200,
        :body => {client_id: 100, name: "New Test", source_url: "http://wat.bro/dawg/"}.to_json)

      api.update_project!(42, name: "New Test", client_id: 100, source_url: "http://wat.bro/dawg/").should == nil

      client.was told_to(:put).with("/v1/projects/42",
        {:name => "New Test", :clientId => 100, :sourceUrl => "http://wat.bro/dawg/"}.to_json,
        {:headers => {'Accept' => 'application/json', 'Content-Type' => 'application/json'}})
    end

    it "does not pass data that is not provided in a project update" do
      client.will_put(
        :status => 200,
        :body => {client_id: 100}.to_json)

      api.update_project!(42, client_id: 100).should == nil

      client.was told_to(:put).with("/v1/projects/42",
        {:clientId => 100}.to_json,
        {:headers => {'Accept' => 'application/json', 'Content-Type' => 'application/json'}})
    end

    context "handles all sorts of response codes" do
      it "handles an 401 response" do
        client.will_get({
          :status => 401,
          :body => {
            "errors" => [
              {
                "code"        => "invalid-id-token",
                "description" => "The given id token is invalid."
              }
            ]
          }.to_json
        })

        begin
          api.find_all_projects
        rescue Warehouse::AuthenticationError => error
          error.errors.should == [
            {
              :code        => :"invalid-id-token",
              :description => "The given id token is invalid."
            }
          ]
        rescue StandardError => error
          fail "Did not catch proper error, instead threw: #{error}"
        end
      end

      it "handles an forbidden response" do
        client.will_get({
          :status => 403,
          :body => {
            "errors" => [
              {
                "code"        => "unauthorized",
                "description" => "You are not authorized to access this resource."
              }
            ]
          }.to_json
        })

        begin
          api.find_all_projects
        rescue Warehouse::AuthorizationError => error
          error.errors.should == [
            {
              :code        => :unauthorized,
              :description => "You are not authorized to access this resource."
            }
          ]
        rescue StandardError => error
          fail "Did not catch proper error, instead threw: #{error}"
        end
      end
    end
  end

  context "clients" do
    it "finds all clients" do
      client.will_get({
        :status => 200,
        :body => {
          "clients" => [
            {
              "id"        => 10,
              "name"      => 'client name',
              "createdAt" => now,
              "updatedAt" => one_day_from_now
            },
            {
              "id"        => 11,
              "name"      => 'client nam1',
              "createdAt" => ten_days_ago,
              "updatedAt" => one_day_from_now
            }
          ]
        }.to_json
      })

      api.find_all_clients.should == [
        {
          :id         => 10,
          :name       => 'client name',
          :created_at => now,
          :updated_at => one_day_from_now
        },
        {
          :id         => 11,
          :name       => 'client nam1',
          :created_at => ten_days_ago,
          :updated_at => one_day_from_now
        }
      ]

      client.was told_to(:get).with("/v1/clients", {:headers => {'Accept' => 'application/json'}, :query => {}})
    end

    it "finds a client by id" do
      client.will_get({
        :status => 200,
        :body => {
          "id"        => 10,
          "name"      => 'client name',
          "createdAt" => now,
          "updatedAt" => one_day_from_now
        }.to_json
      })

      api.find_client_by_id(10).should == {
        :id         => 10,
        :name       => 'client name',
        :created_at => now,
        :updated_at => one_day_from_now
      }
      client.was told_to(:get).with("/v1/clients/10", {:headers => {'Accept' => 'application/json'}, :query => {}})
    end

    it "creates a new client" do
      client.will_post(
        :status => 201,
        :body => '42')

      api.create_client!(name: "Test").should == 42

      client.was told_to(:post).with("/v1/clients",
        {:name => "Test"}.to_json,
        {:headers => {'Accept' => 'application/json', 'Content-Type' => 'application/json'}})
    end

    it "updates an existing client" do
      client.will_put(
        :status => 200,
        :body => {name: "New Test"}.to_json)

      api.update_client!(42, name: "New Test").should == nil

      client.was told_to(:put).with("/v1/clients/42",
        {:name => "New Test"}.to_json,
        {:headers => {'Accept' => 'application/json', 'Content-Type' => 'application/json'}})
    end

    it "does not update fields that are not provided" do
      client.will_put(
        :status => 200,
        :body => {}.to_json)

      api.update_client!(42, {}).should == nil

      client.was told_to(:put).with("/v1/clients/42",
        {}.to_json,
        {:headers => {'Accept' => 'application/json', 'Content-Type' => 'application/json'}})
    end
  end

  context "employements" do
    let(:employments_json) {
      {
        "employments" => [
          {
            "id"        => 10,
            "start"     => ten_days_ago,
            "end"       => four_days_ago,
            "positionId" => 20,
            "position"   => {
              "id" => 20,
              "name" => "Developer",
              "createdAt" => now,
              "updatedAt" => one_day_from_now
            },
            "personId" => 30,
            "person" => {
              "id" => 30,
              "firstName" => "John",
              "lastName" => "Smith",
              "email" => "john@example.com",
              "createdAt" => now,
              "updatedAt" => one_day_from_now
            },
            "createdAt" => now,
            "updatedAt" => one_day_from_now
          },
          {
            "id"        => 11,
            "start"     => five_days_ago,
            "end"       => two_days_ago,
            "positionId" => 21,
            "position"   => {
              "id" => 21,
              "name" => "Admin",
              "createdAt" => now,
              "updatedAt" => one_day_from_now
            },
            "personId" => 31,
            "person" => {
              "id" => 31,
              "firstName" => "John",
              "lastName" => "Smith",
              "email" => "john@example.com",
              "createdAt" => now,
              "updatedAt" => one_day_from_now
            },
            "createdAt" => now,
            "updatedAt" => one_day_from_now
          }
        ]
      }.to_json
    }

    it "updates an employment" do
      client.will_put({
        :status => 200,
        :body => ""
      })

      end_date = Date.new(2002, 3, 4)

      api.update_employment!("1", {
        :end => end_date,
      }).should be_nil

      client.was told_to(:put).with("/v1/employments/1", {
        :end => "2002-03-04",
      }.to_json, {
        :headers => {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        },
      })
    end

    it "gets an employment by id" do
      client.will_get({
        :status => 200,
        :body => {
          "id"        => 10,
          "start"     => ten_days_ago,
          "end"       => four_days_ago,
          "positionId" => 20,
          "position"   => {
            "id" => 20,
            "name" => "Developer",
            "createdAt" => now,
            "updatedAt" => one_day_from_now
          },
          "personId" => 30,
          "person" => {
            "id" => 30,
            "firstName" => "John",
            "lastName" => "Smith",
            "email" => "john@example.com",
            "createdAt" => now,
            "updatedAt" => one_day_from_now
          },
          "createdAt" => now,
          "updatedAt" => one_day_from_now }.to_json
      })

      api.find_employment_by_id(10).should eq({
        :id        => 10,
        :start     => ten_days_ago,
        :end       => four_days_ago,
        :position_id => 20,
        :position => {
          :id => 20,
          :name => "Developer",
          :created_at => now,
          :updated_at => one_day_from_now
        },
        :person_id => 30,
        :person => {
          :id => 30,
          :first_name => "John",
          :last_name => "Smith",
          :email => "john@example.com",
          :created_at => now,
          :updated_at => one_day_from_now
        },
        :created_at => now,
        :updated_at => one_day_from_now
      })

      client.was told_to(:get).with("/v1/employments/10", {:headers=>{"Accept"=>"application/json"}, :query=>{}})
    end

    it "finds all employments" do
      client.will_get({
        :status => 200,
        :body => {
          "employments" => [
            {
              "id"        => 10,
              "start"     => ten_days_ago,
              "end"       => four_days_ago,
              "positionId" => 20,
              "position"   => {
                "id" => 20,
                "name" => "Developer",
                "createdAt" => now,
                "updatedAt" => one_day_from_now
              },
              "personId" => 30,
              "person" => {
                "id" => 30,
                "firstName" => "John",
                "lastName" => "Smith",
                "email" => "john@example.com",
                "createdAt" => now,
                "updatedAt" => one_day_from_now
              },
              "createdAt" => now,
              "updatedAt" => one_day_from_now
            },
            {
              "id"        => 11,
              "start"     => five_days_ago,
              "end"       => two_days_ago,
              "positionId" => 21,
              "position"   => {
                "id" => 21,
                "name" => "Admin",
                "createdAt" => now,
                "updatedAt" => one_day_from_now
              },
              "personId" => 31,
              "person" => {
                "id" => 31,
                "firstName" => "John",
                "lastName" => "Smith",
                "email" => "john@example.com",
                "createdAt" => now,
                "updatedAt" => one_day_from_now
              },
              "createdAt" => now,
              "updatedAt" => one_day_from_now
            }
          ]
        }.to_json
      })

      api.find_all_employments.should == [
        {
          :id        => 10,
          :start     => ten_days_ago,
          :end       => four_days_ago,
          :position_id => 20,
          :position => {
            :id => 20,
            :name => "Developer",
            :created_at => now,
            :updated_at => one_day_from_now
          },
          :person_id => 30,
          :person => {
            :id => 30,
            :first_name => "John",
            :last_name => "Smith",
            :email => "john@example.com",
            :created_at => now,
            :updated_at => one_day_from_now
          },
          :created_at => now,
          :updated_at => one_day_from_now
        },
        {
          :id => 11,
          :start => five_days_ago,
          :end => two_days_ago,
          :position_id => 21,
          :position => {
            :id => 21,
            :name => "Admin",
            :created_at => now,
            :updated_at => one_day_from_now
          },
          :person_id => 31,
          :person => {
            :id => 31,
            :first_name => "John",
            :last_name => "Smith",
            :email => "john@example.com",
            :created_at => now,
            :updated_at => one_day_from_now
          },
          :created_at => now,
          :updated_at => one_day_from_now
        }
      ]

      client.was told_to(:get).with("/v1/employments", {:headers=>{"Accept"=>"application/json"}, :query=>{}})
    end

    it "finds all employments for a location id" do
      client.will_get({
        :status => 200,
        :body => {
          "employments" => [
            {
              "id"        => 10,
              "start"     => ten_days_ago,
              "end"       => four_days_ago,
              "positionId" => 20,
              "position"   => {
                "id" => 20,
                "name" => "Developer",
                "createdAt" => now,
                "updatedAt" => one_day_from_now
              },
              "personId" => 30,
              "person" => {
                "id" => 30,
                "firstName" => "John",
                "lastName" => "Smith",
                "email" => "john@example.com",
                "createdAt" => now,
                "updatedAt" => one_day_from_now
              },
              "createdAt" => now,
              "updatedAt" => one_day_from_now
            },
            {
              "id"        => 11,
              "start"     => five_days_ago,
              "end"       => two_days_ago,
              "positionId" => 21,
              "position"   => {
                "id" => 21,
                "name" => "Admin",
                "createdAt" => now,
                "updatedAt" => one_day_from_now
              },
              "personId" => 31,
              "person" => {
                "id" => 31,
                "firstName" => "John",
                "lastName" => "Smith",
                "email" => "john@example.com",
                "createdAt" => now,
                "updatedAt" => one_day_from_now
              },
              "createdAt" => now,
              "updatedAt" => one_day_from_now
            }
          ]
        }.to_json
      })

      api.find_all_employments({:location_id => 1}).should == [
        {
          :id        => 10,
          :start     => ten_days_ago,
          :end       => four_days_ago,
          :position_id => 20,
          :position => {
            :id => 20,
            :name => "Developer",
            :created_at => now,
            :updated_at => one_day_from_now
          },
          :person_id => 30,
          :person => {
            :id => 30,
            :first_name => "John",
            :last_name => "Smith",
            :email => "john@example.com",
            :created_at => now,
            :updated_at => one_day_from_now
          },
          :created_at => now,
          :updated_at => one_day_from_now
        },
        {
          :id => 11,
          :start => five_days_ago,
          :end => two_days_ago,
          :position_id => 21,
          :position => {
            :id => 21,
            :name => "Admin",
            :created_at => now,
            :updated_at => one_day_from_now
          },
          :person_id => 31,
          :person => {
            :id => 31,
            :first_name => "John",
            :last_name => "Smith",
            :email => "john@example.com",
            :created_at => now,
            :updated_at => one_day_from_now
          },
          :created_at => now,
          :updated_at => one_day_from_now
        }
      ]

      client.was told_to(:get).with("/v1/employments", {:headers=>{"Accept"=>"application/json"}, :query=>{:"location-id"=> 1}})
    end

    it "finds all employments within a time frame" do
      client.will_get({
        :status => 200,
        :body => {
          "employments" => [
            {
              "id"        => 11,
              "start"     => five_days_ago,
              "end"       => one_year_from_now,
              "positionId" => 21,
              "position"   => {
                "id" => 21,
                "name" => "Admin",
                "createdAt" => now,
                "updatedAt" => one_day_from_now
              },
              "personId" => 31,
              "person" => {
                "id" => 31,
                "firstName" => "John",
                "lastName" => "Smith",
                "email" => "john@example.com",
                "createdAt" => now,
                "updatedAt" => one_day_from_now
              },
              "createdAt" => now,
              "updatedAt" => one_day_from_now
            }
          ]
        }.to_json
      })

      api.find_all_employments(start_date: four_days_ago.iso8601, end_date: one_day_from_now.iso8601).should == [
        {
          :id => 11,
          :start => five_days_ago,
          :end => one_year_from_now,
          :position_id => 21,
          :position => {
            :id => 21,
            :name => "Admin",
            :created_at => now,
            :updated_at => one_day_from_now
          },
          :person_id => 31,
          :person => {
            :id => 31,
            :first_name => "John",
            :last_name => "Smith",
            :email => "john@example.com",
            :created_at => now,
            :updated_at => one_day_from_now
          },
          :created_at => now,
          :updated_at => one_day_from_now
        }
      ]

      client.was told_to(:get).with("/v1/employments", {:headers=>{"Accept"=>"application/json"}, :query=>{:"start-date" => four_days_ago.iso8601, :"end-date" => one_day_from_now.iso8601}})
    end

    it "creates an employment with position name" do
      client.will_post({
        :status => 201,
        :body => "1".to_json
      })

      response = api.create_employment!({
        :start => Date.new(2001, 2, 3),
        :end => Date.new(2002, 2, 3),
        :position_name => 'Software Craftsman',
        :person_id => '1'
      })

      response.should == "1"

      client.was told_to(:post).with("/v1/employments", {
        :start => Date.new(2001, 2, 3),
        :end => Date.new(2002, 2, 3),
        :personId => '1',
        :positionName => 'Software Craftsman'
      }.to_json, {
        :headers => {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }
      })
    end

    it "creates an employment with position id" do
      client.will_post({
        :status => 201,
        :body => "1".to_json
      })

      response = api.create_employment!({
        :start => Date.new(2001, 2, 3),
        :end => Date.new(2002, 2, 3),
        :person_id => '1',
        :position_id => '1'
      })

      response.should == "1"

      client.was told_to(:post).with("/v1/employments", {
        :start => Date.new(2001, 2, 3),
        :end => Date.new(2002, 2, 3),
        :personId => '1',
        :positionId => '1'
      }.to_json, {
        :headers => {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }
      })
    end

    it "creates an employment with position id and position name" do
      client.will_post({
        :status => 201,
        :body => "1".to_json
      })

      response = api.create_employment!({
        :start => Date.new(2001, 2, 3),
        :end => Date.new(2002, 2, 3),
        :person_id => '1',
        :position_name => "Software Craftsman",
        :position_id => '1'
      })

      response.should == "1"

      client.was told_to(:post).with("/v1/employments", {
        :start => Date.new(2001, 2, 3),
        :end => Date.new(2002, 2, 3),
        :personId => '1',
        :positionName => "Software Craftsman",
        :positionId => '1'
      }.to_json, {
        :headers => {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }
      })
    end

    it "handles attempt to create invalid employments" do
      client.will_post({
        :status => 422,
        :body => {
          errors: [
            {
              code:        :"employment/missing-start-date",
              description: "A start date is required when creating an employment record."
            }
          ]
        }.to_json
      })

      begin
        api.create_employment!({
          :person_id => '1',
          :position_name => 'Software Craftsman'
        })
      rescue Warehouse::ValidationError => error
        error.errors.should == [
          {
            code:        :"employment/missing-start-date",
            description: "A start date is required when creating an employment record."
          }
        ]
      rescue StandardError => error
        fail "Did not catch proper error, instead threw: #{error}"
      end

      client.was told_to(:post).with("/v1/employments", {
        :start => nil,
        :end => nil,
        :personId => '1',
        :positionName => 'Software Craftsman'
      }.to_json, {
        :headers => {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }
      })
    end
  end

  context "people" do
    it "searches for people" do
      client.will_get({
        :status => 200,
        :body => {
          'people' => [
            {
              'id' => 99,
              'firstName' => 'Some',
              'lastName' => 'Person',
              'email' => 'fake@null.com',
              'createdAt' => now,
              'updatedAt' => one_day_from_now
            }
          ]
        }.to_json
      })

      response = api.search_people({
        :first_name => 'Some',
        :last_name => 'Person',
        :email => 'fake@null.com'
      })

      response.should == [
        {
          :id => 99,
          :first_name => 'Some',
          :last_name => 'Person',
          :email => 'fake@null.com',
          :created_at => now,
          :updated_at => one_day_from_now
        }
      ]

      client.was told_to(:get).with("/v1/people/search", {
        :headers => {
          'Accept' => 'application/json'
        },
        :query => {
          'first-name' => 'Some',
          'last-name' => 'Person',
          'email' => 'fake@null.com'
        }
      })
    end

    it "creates a person" do
      client.will_post({
        :status => 201,
        :body => "1".to_json
      })

      response = api.create_person!({
        :first_name => "Kevin",
        :last_name => "Malone",
        :email => "kmalone@dundermifflin.com"
      })

      response.should == "1"

      client.was told_to(:post).with("/v1/people", {
        :firstName => "Kevin",
        :lastName => "Malone",
        :email => "kmalone@dundermifflin.com"
      }.to_json, {
        :headers => {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }
      })
    end

    it "handles attempt to create invalid person" do
      client.will_post({
        :status => 422,
        :body => {
          :errors => [
            {
              :code        => :"people/missing-last-name",
              :description => "A last name is required to create a person."
            }
          ]
        }.to_json
      })

      begin
        api.create_person!({
          :first_name => "Kevin",
          :email => "kmalone@dundermifflin.com"})
      rescue Warehouse::ValidationError => error
        error.errors.should == [
          {
            :code        => :"people/missing-last-name",
            :description => "A last name is required to create a person."
          }
        ]
      rescue StandardError => error
        fail "Did not catch proper error, instead threw: #{error}"
      end

      client.was told_to(:post).with("/v1/people", {
        :firstName => "Kevin",
        :lastName => nil,
        :email => "kmalone@dundermifflin.com"
      }.to_json, {
        :headers => {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }
      })
    end

    it "finds a person by id" do
      client.will_get({
        :status => 200,
        :body => {
          :id         => 42,
          :created_at => ten_days_ago.to_s,
          :updated_at => four_days_ago.to_s,
          :first_name => "Kevin",
          :last_name  => "Malone",
          :email      => "kmalone@dundermifflin.com"
        }.to_json
      })

      api.find_person_by_id(42).should == {
        :id         => 42,
        :created_at => ten_days_ago,
        :updated_at => four_days_ago,
        :first_name => "Kevin",
        :last_name  => "Malone",
        :email      => "kmalone@dundermifflin.com"
      }

      client.was told_to(:get).with("/v1/people/42", {:headers => {'Accept' => 'application/json'}, :query => {}})
    end

    it "updates a person" do
      client.will_put({
        :status => 200,
        :body => ""
      })

      api.update_person!(42, {:first_name => "Kevin",
                              :last_name => "Malone",
                              :email => "kmalone@dundermifflin.com"}).should == nil

      client.was told_to(:put).with("/v1/people/42", {
        :firstName => "Kevin",
        :lastName => "Malone",
        :email => "kmalone@dundermifflin.com"
      }.to_json, {
        :headers => {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }
      })
    end

    it "does not update fields that are not provided" do
      client.will_put({
        :status => 200,
        :body => ""
      })

      api.update_person!(42, {}).should == nil

      client.was told_to(:put).with("/v1/people/42", {}.to_json, {
        :headers => {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }
      })
    end
  end

  context "engagements" do
    it "creates an engagement" do
      client.will_post({
        :status => 201,
        :body => "1".to_json
      })

      response = api.create_engagement!({
        :start => Date.new(2001, 2, 3),
        :end => Date.new(2002, 3, 4),
        :confidence_percentage => 15,
        :project_id => '15',
        :employment_id => '16'
      })

      response.should == "1"

      client.was told_to(:post).with("/v1/engagements", {
        :start => Date.new(2001, 2, 3),
        :end => Date.new(2002, 3, 4),
        :confidencePercentage => 15,
        :projectId => '15',
        :employmentId => '16'
      }.to_json, {
        :headers => {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }
      })
    end

    it "updates an engagement" do
      client.will_put({
        :status => 200,
        :body => ""
      })

      start_date = Date.new(2001, 2, 3)
      end_date = Date.new(2002, 3, 4)

      api.update_engagement!("1", {
        :start => start_date,
        :end => end_date,
        :confidence_percentage => 95,
        :project_id => '15',
        :employment_id => '16'
      }).should be_nil

      client.was told_to(:put).with("/v1/engagements/1", {
        :employmentId => '16',
        :projectId => '15',
        :confidencePercentage => 95,
        :start => "2001-02-03",
        :end => "2002-03-04"
      }.to_json, {
        :headers => {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        },
      })
    end

    it "does not update fields that are not provided" do
      client.will_put({
        :status => 200,
        :body => ""
      })

      api.update_engagement!("1", {}).should be_nil

      client.was told_to(:put).with("/v1/engagements/1", {}.to_json, {
        :headers => {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        },
      })
    end

    it "deletes an engagement" do
      client.will_delete(status: 200)

      api.delete_engagement!("1").should be_nil

      client.was told_to(:delete).with("/v1/engagements/1", {
        :headers => {
          'Accept' => 'application/json'
        }
      })
    end

    it "finds all engagements" do
      client.will_get({
        :status => 200,
        :body => {
          "engagements" => [
            {
              "id"        => 10,
              "start"     => format_as_date(ten_days_ago),
              "end"       => format_as_date(four_days_ago),
              "createdAt" => now,
              "updatedAt" => one_day_from_now,
              "project" => {
                "id" => 33,
                "name" => "Fun Stuff",
                "createdAt" => now,
                "updatedAt" => one_day_from_now
              },
              "person" => {
                "id" => 34,
                "firstName" => "Ja",
                "lastName" => "Rule",
                "createdAt" => now,
                "updatedAt" => one_day_from_now
              }
            },
            {
              "id"        => 11,
              "start"     => format_as_date(five_days_ago),
              "end"       => format_as_date(two_days_ago),
              "createdAt" => now,
              "updatedAt" => one_day_from_now,
              "project" => {
                "id" => 33,
                "name" => "Fun Stuff",
                "createdAt" => now,
                "updatedAt" => one_day_from_now
              },
              "person" => {
                "id" => 34,
                "firstName" => "Ja",
                "lastName" => "Rule",
                "createdAt" => now,
                "updatedAt" => one_day_from_now
              }
            }
          ]
        }.to_json
      })

      start_date = Date.new(2001,2,3)
      end_date = Date.new(2002,3,4)

      response = api.find_all_engagements({:start => start_date, :end => end_date})

      response.should == [
        {
          :id         => 10,
          :start      => ten_days_ago.to_date,
          :end        => four_days_ago.to_date,
          :created_at => now,
          :updated_at => one_day_from_now,
          :project => {
            :id => 33,
            :name => "Fun Stuff",
            :created_at => now,
            :updated_at => one_day_from_now
          },
          :person => {
            :id => 34,
            :first_name => "Ja",
            :last_name => "Rule",
            :created_at => now,
            :updated_at => one_day_from_now
          }
        },
        {
          :id         => 11,
          :start      => five_days_ago.to_date,
          :end        => two_days_ago.to_date,
          :created_at => now,
          :updated_at => one_day_from_now,
          :project => {
            :id => 33,
            :name => "Fun Stuff",
            :created_at => now,
            :updated_at => one_day_from_now
          },
          :person => {
            :id => 34,
            :first_name => "Ja",
            :last_name => "Rule",
            :created_at => now,
            :updated_at => one_day_from_now
          }
        }
      ]

      client.was told_to(:get).with("/v1/engagements", {:headers=>{"Accept"=>"application/json"}, :query => {"end" => "2002-03-04", "start" => "2001-02-03"}})
    end

    it "finds all engagements by project_id" do
      client.will_get({
        :status => 200,
        :body => {
          "engagements" => []
        }.to_json
      })

      response = api.find_all_engagements({:project_id => 12})

      client.was told_to(:get).with("/v1/engagements", {:headers=>{"Accept"=>"application/json"}, :query => {"project-id" => 12}})
    end

    it "finds an engagement by id" do
      client.will_get({
        :status => 200,
        :body => {
          "id"           => 10,
          "projectId"    => "abc",
          "employmentId" => "def",
          "start"        => format_as_date(ten_days_ago),
          "end"          => format_as_date(four_days_ago),
          "createdAt"    => now,
          "updatedAt"    => one_day_from_now
        }.to_json
      })

      response = api.find_engagement_by_id("10")

      response.should == {
        :id            => 10,
        :project_id    => "abc",
        :employment_id => "def",
        :start         => ten_days_ago.to_date,
        :end           => four_days_ago.to_date,
        :created_at    => now,
        :updated_at    => one_day_from_now
      }

      client.was told_to(:get).with("/v1/engagements/10", {:headers=>{"Accept"=>"application/json"}, :query => {}})
    end

    it "find an engagement by id returns nil if it does not exist" do
      client.will_get(status: 404)

      api.find_engagement_by_id("10").should be_nil
    end
  end

  context "apprenticeships" do
    it "creates an apprenticeship" do
      start_date =  Date.new(2014, 01, 13)
      end_date =  Date.new(2014, 01, 19)

      client.will_post({
        :status => 201,
        :body => "1".to_json
      })

      response = api.create_apprenticeship!({
        :person_id => 1,
        :skill_level => "resident",
        :start => start_date,
        :end => end_date,
        :mentorships => [{
          :person_id => 2,
          :start => start_date,
          :end => end_date
        }]
      })

      client.was told_to(:post).with("/v1/apprenticeships", {
        :personId => 1,
        :skillLevel => "resident",
        :start => start_date,
        :end => end_date,
        :mentorships => [{
          :personId => 2,
          :start => start_date,
          :end => end_date
        }]}.to_json, {
          :headers => {
            'Accept' => 'application/json',
            'Content-Type' => 'application/json'
          }
        })
    end

    let(:parsed_apprenticeship) {{
      :id => 10,
      :created_at => now,
      :updated_at => now,
      :person_id => 1,
      :skill_level => "resident",
      :start => ten_days_ago,
      :end => four_days_ago,
      :mentorships => [{
        :person_id => 2,
        :start => ten_days_ago,
        :end => four_days_ago
      }]
    }}

    let(:apprenticeship_json_values) {{
      "id" => 10,
      "createdAt" => now,
      "updatedAt" => now,
      "personId" => 1,
      "skillLevel" => "resident",
      "start" => ten_days_ago,
      "end" => four_days_ago,
      "mentorships" => [{
        "personId" => 2,
        "start" => ten_days_ago,
        "end" => four_days_ago
      }]
    }}

    it "finds an apprenticeship by id" do
      client.will_get({
        :status => 200,
        :body => apprenticeship_json_values.to_json
      })

      response = api.find_apprenticeship_by_id("1")

      response.should == parsed_apprenticeship
    end

    it "finds all apprenticeships" do
      client.will_get({
        :status => 200,
        :body => {
          "apprenticeships" => [apprenticeship_json_values, apprenticeship_json_values]
        }.to_json
      })

      response = api.find_all_apprenticeships

      response.should == [parsed_apprenticeship, parsed_apprenticeship]
    end

    it "finds all upcoming apprentice graduations grouped by location" do
      client.will_get({
        :status => 200,
        :body => [{
          "locationName" => "Chicago",
          "currentApprentices" => [{
            "firstName" => "Bob",
            "lastName" => "Dole",
            "graduatesAt" => "2000-01-01T12:00:00Z"
          }]
        }, {
          "locationName" => "London",
          "currentApprentices" => [{
            "firstName" => "George",
            "lastName" => "Bush",
            "graduatesAt" => "2000-01-01T12:00:00Z"
          }]
        }].to_json
      })

      response = api.upcoming_apprentice_graduations_grouped_by_location

      response.should == [{
          :location_name => "Chicago",
          :current_apprentices => [{
            :first_name => "Bob",
            :last_name => "Dole",
            :graduates_at => Time.parse("2000-01-01T12:00:00Z")
          }]
        }, {
          :location_name => "London",
          :current_apprentices => [{
            :first_name => "George",
            :last_name => "Bush",
            :graduates_at => Time.parse("2000-01-01T12:00:00Z")
          }]
      }]
    end
  end

  context "directors" do
    let(:director_1) {{
      "firstName" => "Steven",
      "lastName" => "Spielberg",
      "email" => "steve@example.com",
      "createdAt" => now,
      "updatedAt" => now
    }}
    let(:director_2) {{
      "firstName" => "Martin",
      "lastName" => "Scorcese",
      "email" => "martin@example.com",
      "createdAt" => now,
      "updatedAt" => now
    }}

    it "gets current directors" do
      client.will_get({
        :status => 200,
        :body => {
          "directors" => [
            director_1,
            director_2
          ]
        }.to_json
      })

      response = api.find_current_directors

      client.was told_to(:get).with("/v1/directors/current", {
        :headers => {
          'Accept' => 'application/json'
        },
        :query => {}
      })
      expect(response).to eq([
        {
          first_name: "Steven",
          last_name: "Spielberg",
          email: "steve@example.com",
          created_at: now,
          updated_at: now
        },
        {
          first_name: "Martin",
          last_name: "Scorcese",
          email: "martin@example.com",
          created_at: now,
          updated_at: now
        }
      ])
    end

    it "gets director engagements" do
      client.will_get({
        :status => 200,
        :body => {
          "directorEngagements" => [
            {
              "id"        => 10,
              "start"     => format_as_date(ten_days_ago),
              "end"       => format_as_date(four_days_ago),
              "projectId" => 1,
              "employmentId" => 2,
              "createdAt" => now,
              "updatedAt" => one_day_from_now
            }
          ]
        }.to_json
      })

      response = api.find_director_engagements_by_person_id(1)

      client.was told_to(:get).with("/v1/directors/1/director-engagements", {
        :headers => {
          'Accept' => 'application/json'
        },
        :query => {}
      })
      expect(response).to eq([
        {
          id:            10,
          start:         ten_days_ago.to_date,
          end:           four_days_ago.to_date,
          project_id:    1,
          employment_id: 2,
          created_at:    now,
          updated_at:    one_day_from_now
        }
      ])
    end

    it "finds a director engagement by id" do
      client.will_get({
        :status => 200,
        :body => director_1.to_json
      })

      response = api.find_director_engagement_by_id(1)
      response[:first_name].should == "Steven"
      response[:last_name].should == "Spielberg"
      response[:email].should == "steve@example.com"
      response[:created_at].should == now
      response[:updated_at].should == now

      client.was told_to(:get).with("/v1/director-engagements/1", {
        :headers => {
          'Accept' => 'application/json'
        },
        :query => {}
      })
    end

    it "creates a new director engagement" do
      client.will_post({
        :status => 201,
        :body => "1"
      })

      api.create_director_engagement!({:person_id => 42,
                                       :project_id => 24,
                                       :start => now})

      client.was told_to(:post).with("/v1/director-engagements", {
        'personId' => 42,
        'projectId' => 24,
        'start' => format_as_date(now),
        'end' => nil
      }.to_json, {
        :headers => {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }
      })
    end

    it "updates an existing director engagement" do
      client.will_put({
        :status => 200,
        :body => ""
      })

      api.update_director_engagement!(1, {:end => now})

      client.was told_to(:put).with("/v1/director-engagements/1", {
        'end' => format_as_date(now)
      }.to_json, {
        :headers => {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }
      })
    end

    it "does not update fields that are not provided" do
      client.will_put({
        :status => 200,
        :body => ""
      })

      api.update_director_engagement!(1, {})

      client.was told_to(:put).with("/v1/director-engagements/1", {}.to_json, {
        :headers => {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }
      })
    end
  end

  context "locations" do
    it "finds all locations" do
      client.will_get({
        :status => 200,
        :body => {
          "locations" => [
            {
              "id"        => 10,
              "name"      => "Chicago",
              "createdAt" => now,
              "updatedAt" => one_day_from_now,
            },
            {
              "id"        => 11,
              "name"      => "London",
              "createdAt" => now,
              "updatedAt" => one_day_from_now,
            },
            {
              "id"        => 12,
              "name"      => "New York",
              "createdAt" => now,
              "updatedAt" => one_day_from_now,
            }
          ]
        }.to_json
      })

      response = api.find_all_locations

      response.should == [
        {
          :id         => 10,
          :name       => "Chicago",
          :created_at => now,
          :updated_at => one_day_from_now,
        },
        {
          :id         => 11,
          :name       => "London",
          :created_at => now,
          :updated_at => one_day_from_now,
        },
        {
          :id         => 12,
          :name       => "New York",
          :created_at => now,
          :updated_at => one_day_from_now,
        }
      ]

      client.was told_to(:get).with("/v1/locations", {:headers=>{"Accept"=>"application/json"}, :query => {}})
    end
  end
end
