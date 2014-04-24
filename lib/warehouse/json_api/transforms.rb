require 'active_support/inflector'
require 'active_support/core_ext/hash'

module Warehouse
  class JsonAPI
    class Transforms
      DATE_FORMAT = "%Y-%m-%d"

      class << self

        def rubyize(thing)
          case
          when thing.is_a?(Array)
            thing.map do |item|
              rubyize(item)
            end
          when thing.is_a?(Hash)
            hash = thing.transform_keys { |key| ActiveSupport::Inflector.underscore(key) }.symbolize_keys
            hash.reduce({}) do |acc, (k, v)|
              acc[k] = rubyize(v)
              acc
            end
          else
            thing
          end
        end

        def kebabize(thing)
          case
          when thing.is_a?(Hash)
            thing.reduce({}) do |acc, (k, v)|
              acc[k.to_s.gsub("_", "-")] = kebabize(v)
              acc
            end
          else
            thing
          end
        end

        def jsonize(thing)
          case
          when thing.is_a?(Array)
            thing.map do |item|
              jsonize(item)
            end
          when thing.is_a?(Hash)
            hash = thing.transform_keys { |key| ActiveSupport::Inflector.camelize(key, false) }
            hash.reduce({}) do |acc, (k, v)|
              acc[k] = jsonize(v)
              acc
            end
          else
            thing
          end
        end

        def update_in(hash, key)
          hash.merge({
            key => yield(hash[key])
          })
        end

        def maybe_transform_value(hash, k)
          if hash.has_key?(k)
            update_in(hash, k) do |v|
              yield(v)
            end
          else
            hash
          end
        end

        def parse_time_value(hash, key)
          maybe_transform_value(hash, key) do |v|
            if v
              Time.parse(v)
            end
          end
        end

        def format_as_date(date)
          date.strftime(DATE_FORMAT) unless date.nil?
        end

        def parse_date_value(hash, key)
          maybe_transform_value(hash, key) do |v|
            if v
              Date.strptime(v, DATE_FORMAT)
            end
          end
        end

        def parse_timestamps(hash)
          hash = parse_time_value hash, :updated_at
          hash = parse_time_value hash, :created_at
          hash
        end

        def rubyize_errors(errors)
          rubyize(errors).map do |error|
            maybe_transform_value(error, :code) { |code| code.to_sym }
          end
        end
      end
    end
  end
end
