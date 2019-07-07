# frozen_string_literal: true

require 'sequel'
require 'forwardable'

module Rack::Scaffold::Adapters
  class Sequel < Base
    extend Forwardable

    def_delegators :@klass, :count, :all, :find, :[], :update_timestamp_field
    def_delegator :@klass, :create, :create!
    def_delegator :@klass, :update, :update!
    def_delegator :@klass, :destroy, :destroy!

    class << self
      def ===(model)
        ::Sequel::Model === model
      end

      def resources(model, _options = {})
        model
      end
    end

    def singular
      @klass.name.demodulize.downcase
    end

    def plural
      @klass.table_name
    end

    def paginate(limit, offset)
      @klass.limit(limit, offset)
    end

    def one_to_many_associations
      @klass.all_association_reflections.select { |association| association[:type] == :one_to_many }.collect { |association| association[:name] }
    end

    def timestamps?
      defined?(::Sequel::Plugins::Timestamps) && @klass.plugins.include?(::Sequel::Plugins::Timestamps)
    end
  end
end
