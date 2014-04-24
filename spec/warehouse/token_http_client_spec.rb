require 'warehouse/token_http_client'
require 'warehouse/mock_http_client'
require 'surrogate/rspec'
require 'webmock/rspec'

describe Warehouse::TokenHttpClient do

  it 'implements the http api interface' do
    described_class.should substitute_for(Warehouse::MockHttpClient)
  end

  it 'makes a get request with the id token' do
    response = {status: 403, body: "a body", headers: {}}

    request = stub_request(:get, "http://google.com/path").
      with(headers: {'Authorization' => 'Token abcd'}).
      to_return(response)

    client = described_class.new(:host => "http://google.com", :id_token => "abcd")
    client.get("/path").should == response

    assert_requested(request)
  end

  it 'adds query params to the get request' do
    response = {status: 200, body: "a body", headers: {}}
    request = stub_request(:get, "http://google.com/path").
      with(headers: {'Authorization' => 'Token abcd'}, query: {:a => :b}).
      to_return(response)

    client = described_class.new(:host => "http://google.com", :id_token => "abcd")
    client.get("/path", {:query => {:a => :b}}).should == response

    assert_requested(request)
  end

  it 'adds headers to the get request' do
    response = {status: 200, body: "a body", headers: {}}
    request = stub_request(:get, "http://google.com/path").
      with(headers: {'Authorization' => 'Token abcd', 'Accept' => 'application/xml'}).
      to_return(response)

    client = described_class.new(:host => "http://google.com", :id_token => "abcd")
    client.get("/path", {:headers => {'Accept' => 'application/xml'}}).should == response

    assert_requested(request)
  end

  it 'includes the bearer authorization header if only an access token is provided during a get request' do
    response = {status: 201, body: "1".to_json, headers: {}}
    request = stub_request(:get, "http://google.com/path").
      with(headers: {'Authorization' => 'Bearer abcd', 'Accept' => 'application/xml'}).
      to_return(response)

    client = described_class.new(:host => "http://google.com", :access_token => "abcd")
    client.get("/path", {:headers => {'Accept' => 'application/xml'}}).should == response

    assert_requested(request)
  end

  it 'makes a post request with the id token' do
    response = {status: 201, body: "1".to_json, headers: {}}
    request = stub_request(:post, "http://google.com/path").
      with(headers: {'Authorization' => 'Token abcd'},
           body: "some data").
      to_return(response)

    client = described_class.new(:host => "http://google.com", :id_token => "abcd")
    client.post("/path", "some data").should == response

    assert_requested(request)
  end

  it 'adds headers to the post request' do
    response = {status: 201, body: "1".to_json, headers: {}}
    request = stub_request(:post, "http://google.com/path").
      with(headers: {'Authorization' => 'Token abcd', 'Accept' => 'application/json'},
           body: "some data").
      to_return(response)

    client = described_class.new(:host => "http://google.com", :id_token => "abcd")
    client.post("/path", "some data", {:headers => {'Accept' => 'application/json'}}).should == response

    assert_requested(request)
  end

  it 'includes the bearer authorization header if only an access token is provided during a post request' do
    response = {status: 201, body: "1".to_json, headers: {}}
    request = stub_request(:post, "http://google.com/path").
      with(headers: {'Authorization' => 'Bearer abcd', 'Accept' => 'application/xml'},
           body: "some data").
      to_return(response)

    client = described_class.new(:host => "http://google.com", :access_token => "abcd")
    client.post("/path", "some data", {:headers => {'Accept' => 'application/xml'}}).should == response

    assert_requested(request)
  end

  it 'makes a put request' do
    response = {status: 201, body: "1".to_json, headers: {}}
    request = stub_request(:put, "http://google.com/path").
      with(headers: {'Authorization' => 'Token abcd'},
           body: "some data").
      to_return(response)

    client = described_class.new(:host => "http://google.com", :id_token => "abcd")
    client.put("/path", "some data").should == response

    assert_requested(request)
  end

  it 'adds headers to the put request' do
    response = {status: 201, body: "1".to_json, headers: {}}
    request = stub_request(:put, "http://google.com/path").
      with(headers: {'Authorization' => 'Token abcd', 'Accept' => 'application/json'},
           body: "some data").
      to_return(response)

    client = described_class.new(:host => "http://google.com", :id_token => "abcd")
    client.put("/path", "some data", {:headers => {'Accept' => 'application/json'}}).should == response

    assert_requested(request)
  end

  it 'includes the bearer authorization header if only an access token is provided during a put request' do
    response = {status: 201, body: "1".to_json, headers: {}}
    request = stub_request(:put, "http://google.com/path").
      with(headers: {'Authorization' => 'Bearer abcd', 'Accept' => 'application/xml'},
           body: "some data").
      to_return(response)

    client = described_class.new(:host => "http://google.com", :access_token => "abcd")
    client.put("/path", "some data", {:headers => {'Accept' => 'application/xml'}}).should == response

    assert_requested(request)
  end

  it 'makes a delete request' do
    response = {status: 201, body: "1".to_json, headers: {}}
    request = stub_request(:delete, "http://google.com/path").
      with(headers: {'Authorization' => 'Token abcd'}).
      to_return(response)

    client = described_class.new(:host => "http://google.com", :id_token => "abcd")
    client.delete("/path").should == response

    assert_requested(request)
  end

  it 'adds headers to the delete request' do
    response = {status: 201, body: "1".to_json, headers: {}}
    request = stub_request(:delete, "http://google.com/path").
      with(headers: {'Authorization' => 'Token abcd', 'Accept' => "application/json"}).
      to_return(response)

    client = described_class.new(:host => "http://google.com", :id_token => "abcd")
    client.delete("/path", :headers => {'Accept' => 'application/json'}).should == response

    assert_requested(request)
  end

  it 'includes the bearer authorization header if only an access token is provided during a delete request' do
    response = {status: 201, body: "1".to_json, headers: {}}
    request = stub_request(:delete, "http://google.com/path").
      with(headers: {'Authorization' => 'Bearer abcd', 'Accept' => 'application/xml'}).
      to_return(response)

    client = described_class.new(:host => "http://google.com", :access_token => "abcd")
    client.delete("/path", {:headers => {'Accept' => 'application/xml'}}).should == response

    assert_requested(request)
  end

end
