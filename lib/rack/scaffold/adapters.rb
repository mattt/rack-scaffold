module Rack
  class Scaffold
    def self.adapters
      @@adapters ||= []
    end

    module Adapters
      class NotImplementedError < StandardError; end

      class Base
        attr_reader :klass

        class << self
          def inherited(adapter)
            ::Rack::Scaffold.adapters << adapter
            super
          end

          def ===(model)
            raise NotImplementedError
          end

          def resources(model, options = {})
            raise NotImplementedError
          end
        end

        def initialize(klass)
          @klass = klass
        end

        def singular
          raise NotImplementedError
        end

        def plural
          raise NotImplementedError
        end

        def count
          raise NotImplementedError
        end

        def all
          raise NotImplementedError
        end

        def paginate(offset, limit)
          raise NotImplementedError
        end

        def [](id)
          raise NotImplementedError
        end

        def one_to_many_associations
          raise NotImplementedError
        end

        def find(options = {})
          raise NotImplementedError
        end

        def create!(attributes = {})
          raise NotImplementedError
        end

        def update!(attributes = {})
          raise NotImplementedError
        end

        def destroy!
          raise NotImplementedError
        end

        def timestamps?
          raise NotImplementedError
        end

        def update_timestamp_field
          raise NotImplementedError
        end

        def method_missing(method, *args, &block)
          @klass.send(method)
        end
      end
    end
  end
end

require 'rack/scaffold/adapters/active_record' if defined?(ActiveRecord::Base)
require 'rack/scaffold/adapters/sequel' if defined?(Sequel)
require 'rack/scaffold/adapters/core_data' if defined?(Sequel) and defined?(CoreData)
