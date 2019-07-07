# frozen_string_literal: true

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

          def ===(_model)
            raise NotImplementedError
          end

          def resources(_model, _options = {})
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

        def paginate(_offset, _limit)
          raise NotImplementedError
        end

        def [](_id)
          raise NotImplementedError
        end

        def one_to_many_associations
          raise NotImplementedError
        end

        def find(_options = {})
          raise NotImplementedError
        end

        def create!(_attributes = {})
          raise NotImplementedError
        end

        def update!(_attributes = {})
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

        def method_missing(method, *_args)
          @klass.send(method)
        end
      end
    end
  end
end

require 'rack/scaffold/adapters/active_record' if defined?(ActiveRecord::Base)
require 'rack/scaffold/adapters/sequel' if defined?(Sequel)
require 'rack/scaffold/adapters/core_data' if defined?(Sequel) && defined?(CoreData)
