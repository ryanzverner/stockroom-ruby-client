require 'httparty'

module Warehouse
  class TokenHttpClient

    def initialize(options)
      @host = options[:host]
      @id_token = options[:id_token]
      @access_token = options[:access_token]
    end

    def get(path, options={})
      headers = add_headers(default_headers, options[:headers])
      query_options = {:headers => headers}
      if query = options[:query]
        if !query.empty?
          query_options[:query] = query
        end
      end
      response = HTTParty.get(url(path), query_options)
      response_to_hash(response)
    end

    def post(path, data, options={})
      headers = add_headers(default_headers, options[:headers])
      response = HTTParty.post(url(path), {
        :headers => headers,
        :body => data
      })
      response_to_hash(response)
    end

    def put(path, data, options={})
      headers = add_headers(default_headers, options[:headers])
      response = HTTParty.put(url(path), {
        :headers => headers,
        :body => data
      })
      response_to_hash(response)
    end

    def delete(path, options={})
      headers = add_headers(default_headers, options[:headers])
      response = HTTParty.delete(url(path), {
        :headers => headers
      })
      response_to_hash(response)
    end

    private

    attr_reader :id_token, :access_token, :host

    def url(path)
      host + path
    end

    def response_to_hash(response)
      {
        :status => response.code,
        :headers => response.headers,
        :body => response.body
      }
    end

    def default_headers
      if id_token
        {"Authorization" => "Token #{id_token}"}
      elsif access_token
        {"Authorization" => "Bearer #{access_token}"}
      end
    end

    def add_headers(all_headers, to_add)
      if to_add
        all_headers.merge(to_add)
      else
        all_headers
      end
    end

  end
end
