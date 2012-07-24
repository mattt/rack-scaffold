require 'rack'
require 'sinatra/base'

require 'sequel'
require 'active_support/inflector'

require 'rack/core-data/data_model'
require 'rack/core-data/version'

module Rack::CoreData::Models
end

module Rack
  def self.CoreData(xcdatamodel)
    app = Class.new(Sinatra::Base) do
      before do
        content_type :json
      end
    end

    model = CoreData::DataModel.new(xcdatamodel)

    # Create each model class before implementing, in order to correctly set up relationships
    model.entities.each do |entity|
      klass = Rack::CoreData::Models.const_set(entity.name.capitalize, Class.new(Sequel::Model))
    end

    model.entities.each do |entity|
      klass = Rack::CoreData::Models.const_get(entity.name.capitalize)
      klass.dataset = entity.name.downcase.pluralize.to_sym

      klass.class_eval do
        strict_param_setting = false
        plugin :json_serializer, :naked => true, :include => :url, :except => :id 
        plugin :schema

        def url
          "/#{self.class.table_name}/#{id}"
        end

        entity.relationships.each do |relationship|
          options = {:class => Rack::CoreData::Models.const_get(relationship.destination.capitalize)}

          if relationship.to_many?
            one_to_many relationship.name.to_sym, options
          else
            many_to_one relationship.name.to_sym, options
          end
        end

        set_schema do
          primary_key :id

          entity.attributes.each do |attribute|
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
                    when "Decimal" then :float8
                    when "Date" then :timestamp
                    when "Boolean" then :boolean
                    when "Binary" then :bytea
                    else :varchar
                   end

            column attribute.name, type, options
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

        create_table unless table_exists?
      end

      app.class_eval do
        include Rack::CoreData::Models
        klass = Rack::CoreData::Models.const_get(entity.name.capitalize)

        get "/#{entity.name.downcase.pluralize}/?" do
          klass.all.to_json
        end

        post "/#{entity.name.downcase.pluralize}/?" do
          record = klass.new(params)
          if record.save
            status 201
            record.to_json
          else
            status 406
            record.errors.to_json
          end
        end
        
        get "/#{entity.name.downcase.pluralize}/:id/?" do
          klass[params[:id]].to_json
        end

        put "/#{entity.name.downcase.pluralize}/:id/?" do
          record = klass[params[:id]] or halt 404
          if record.update(params)
            status 200
            record.to_json
          else
            status 406
            record.errors.to_json
          end
        end
        
        delete "/#{entity.name.downcase.pluralize}/:id/?" do
          record = klass[params[:id]] or halt 404
          if record.destroy
            status 200
          else
            status 406
            record.errors.to_json
          end
        end

        entity.relationships.each do |relationship|
          next unless relationship.to_many?

          get "/#{entity.name.downcase.pluralize}/:id/#{relationship.name}/?" do
            klass[params[:id]].send(relationship.name).to_json
          end
        end
      end
    end

    return app
  end
end
