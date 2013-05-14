require 'active_record'
require 'forwardable'

module Rack::Scaffold::Adapters
  class ActiveRecord < Base
    extend Forwardable

    def_delegators :@klass, :count, :all, :find, :create!, :update!, :destroy!

    class << self
      def ===(model)
        ::ActiveRecord::Base === model
      end

      def resources(model)
        model
      end

      def timestamps?
        record_timestamps?
      end
    end

    def singular
      @klass.name.downcase
    end

    def plural
      @klass.table_name
    end

    def paginate(limit, offset)
      @klass.limit(limit).offset(offset)
    end

    def [](id)
      self.find(id)
    end

    def update_timestamp_field
      self.attribute_names.include?("updated_at") ? "updated_at" : "updated_on"
    end
  end
end
