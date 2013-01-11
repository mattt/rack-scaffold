require 'rack'
require 'sinatra/base'
require 'sinatra/param'

require 'sequel'
require 'active_support/inflector'

require 'rack/core-data/data_model'
require 'rack/core-data/version'

module Rack::CoreData::Models
end

module Rack
  def self.CoreData(xcdatamodel)
    model = CoreData::DataModel.new(xcdatamodel)

    # Create each model class before implementing, in order to correctly set up relationships
    model.entities.each do |entity|
      klass = Rack::CoreData::Models.const_set(entity.name.capitalize, Class.new(Sequel::Model))
    end

    app = Class.new(Sinatra::Base) do
      before do
        content_type :json
      end

      helpers Sinatra::Param

      options '/' do
        links = []
        model.entities.each do |entity|
          links << %{</#{entity.name.downcase.pluralize}>; rel="resource"}
        end

        response['Link'] = links.join("\n")

        model.entities.collect{ |entity| 
          {
            name: entity.name, 
            url: "/#{entity.name.downcase.pluralize}",
            columns: entity.attributes.collect(&:name)
          }
        }.to_json
      end
    end

    model.entities.each do |entity|
      klass = Rack::CoreData::Models.const_get(entity.name.capitalize)
      klass.dataset = entity.name.downcase.pluralize.to_sym

      klass.class_eval do
        self.strict_param_setting = false
        self.raise_on_save_failure = false

        plugin :json_serializer, naked: true, only: [:url] + (columns & entity.attributes.collect{|attribute| attribute.name.to_sym})
        plugin :schema
        plugin :validation_helpers

        def url
          "/#{self.class.table_name}/#{self[primary_key]}"
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

        create_table unless table_exists?
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

      app.class_eval do
        include Rack::CoreData::Models
        klass = Rack::CoreData::Models.const_get(entity.name.capitalize)

        disable :raise_errors, :show_exceptions

        get "/#{klass.table_name}/?" do
          if params[:page] or params[:per_page]
            param :page, Integer, default: 1, min: 1
            param :per_page, Integer, default: 100, in: (1..100)

            {
              "#{klass.table_name}" => klass.limit(params[:per_page], (params[:page] - 1) * params[:per_page]),
              page: params[:page],
              total: klass.count
            }.to_json
          else
            param :limit, Integer, default: 100, in: (1..100)
            param :offset, Integer, default: 0, min: 0

            klass.limit(params[:limit], params[:offset]).to_json
          end
        end

        post "/#{klass.table_name}/?" do
          record = klass.new(params)
          if record.save
            status 201
            record.to_json
          else
            status 406
            {errors: record.errors}.to_json
          end
        end
        
        get "/#{klass.table_name}/:id/?" do
          record = klass[params[:id]] or halt 404
          record.to_json
        end

        put "/#{klass.table_name}/:id/?" do
          record = klass[params[:id]] or halt 404
          if record.update(params)
            status 200
            record.to_json
          else
            status 406
            {errors: record.errors}.to_json
          end
        end
        
        delete "/#{klass.table_name}/:id/?" do
          record = klass[params[:id]] or halt 404
          if record.destroy
            status 200
          else
            status 406
            {errors: record.errors}.to_json
          end
        end

        entity.relationships.each do |relationship|
          next unless relationship.to_many?

          get "/#{klass.table_name}/:id/#{relationship.name}/?" do
            klass[params[:id]].send(relationship.name).to_json
          end
        end
      end
    end

    return app
  end
end

require 'rack/core-data/admin'
