require 'core_data'
require 'sequel'
require 'active_support/inflector'

module Rack::Scaffold::Adapters
  class CoreData < Sequel
    class << self
      def ===(model)
        return true if ::CoreData::DataModel === model
        !! ::CoreData::DataModel.new(model) rescue false
      end

      def resources(xcdatamodel, options = {})
        model = ::CoreData::DataModel.new(xcdatamodel)
        resources = model.entities.collect{|entity| resource = new(entity, options)}
        model.entities.each do |entity|
          resources.each do |resource|
            resource.establish_associations!(entity)
          end
        end

        return resources
      end
    end

    def initialize(entity, options = {})
      klass = Class.new(::Sequel::Model)
      klass.dataset = entity.name.downcase.pluralize.to_sym

      klass.class_eval do
        alias :update! :update
        alias :destroy! :destroy

        self.strict_param_setting = false
        self.raise_on_save_failure = false

        plugin :json_serializer, naked: true, include: [:url]
        plugin :schema
        plugin :validation_helpers

        if options[:timestamps]
          if options[:timestamps].instance_of? Hash
            plugin :timestamps, options[:timestamps]
          else
            plugin :timestamps
          end
        end

        def url
          "/#{self.class.table_name}/#{self[primary_key]}"
        end

        set_schema do
          primary_key :id

          entity.attributes.each do |attribute|
            next if attribute.transient?

            options = {
              :null => attribute.optional?,
              :index => attribute.indexed?,
              :default => attribute.default_value
            }

            type = case attribute.type
                   when "Integer 16" then :int2
                   when "Integer 32" then :int4
                   when "Integer 64" then :int8
                   when "Float" then :float4
                   when "Double" then :float8
                   when "Decimal" then :float8
                   when "Date" then :timestamp
                   when "Boolean" then :boolean
                   when "Binary" then :bytea
                   else :varchar
                   end

            column attribute.name.to_sym, type, options
          end

          entity.relationships.each do |relationship|
            options = {
              :index => true,
              :null => relationship.optional?
            }

            if not relationship.to_many?
              column "#{relationship.name}_id".to_sym, :integer, options
            end
          end
        end

        if table_exists?
          missing_columns = schema.columns.reject{|c| columns.include?(c[:name])}
          db.alter_table table_name do
            missing_columns.each do |options|
              add_column options.delete(:name), options.delete(:type), options
            end
          end
        else
          create_table
        end
      end

      klass.send :define_method, :validate do
        entity.attributes.each do |attribute|
          case attribute.type
          when "Integer 16", "Integer 32", "Integer 64"
            validates_integer attribute.name
          when "Float", "Double", "Decimal"
            validates_numeric attribute.name
          when "String"
            validates_min_length attribute.minimum_value, attribute.name if attribute.minimum_value
            validates_max_length attribute.maximum_value, attribute.name if attribute.maximum_value
          end
        end
      end

      super(CoreData.const_set(entity.name, klass))
    end

    def establish_associations!(entity)
      klass.class_eval do
        entity.relationships.each do |relationship|
          options = {:class => CoreData.const_get(relationship.destination.camelize)}

          options = {}
          if relationship.to_many?
            one_to_many relationship.name.to_sym, options
          else
            many_to_one relationship.name.to_sym, options
          end
        end
      end
    end
  end
end
