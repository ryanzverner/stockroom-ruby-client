require 'surrogate'

module Warehouse
  class MockHttpClient
    Surrogate.endow self

    define(:get) do |path, query={}|
    end

    define(:post) do |path, data, options={}|
    end

    define(:put) do |path, data, options={}|
    end

    define(:delete) do |path, options={}|
    end

  end
end
