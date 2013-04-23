require 'rack'
require 'rack/contrib'
require 'sinatra/base'
require 'sinatra/param'

require 'rack/scaffold/version'
require 'rack/scaffold/adapters'

module Rack
  class Scaffold
    ACTIONS = [:create, :read, :update, :destroy]

    def initialize(options = {})
      raise ArgumentError, "Missing option: :model or :models" unless options[:model] or options[:models]

      if options[:models] and options[:models].kind_of?(Array)
        @app = Rack::Cascade.new(options.delete(:models).collect{|model| self.class.new(options.dup.merge({model: model}))}) and return
      end

      @app = Class.new(Sinatra::Base) do
        use Rack::PostBodyContentTypeParser
        helpers Sinatra::Param

        before do
          content_type :json
        end

        disable :raise_errors, :show_exceptions
      end

      @actions = (options[:only] || ACTIONS) - (options[:except] || [])

      @adapter = Rack::Scaffold.adapters.detect{|adapter| adapter === options[:model]}
      raise "No suitable adapters found for #{options[:model]} in #{Rack::Scaffold.adapters}" unless @adapter

      resources = Array(@adapter.resources(options[:model]))
      resources.each do |resource|
        @app.instance_eval do
          post "/#{resource.plural}/?" do
            if record = resource.create!(params)
              status 201
              {entity.name.downcase => record}.to_json
            else
              status 406
              {errors: record.errors}.to_json
            end
          end
        end if @actions.include?(:create)

        @app.instance_eval do
          get "/#{resource.plural}/?" do
            if params[:page] or params[:per_page]
              param :page, Integer, default: 1, min: 1
              param :per_page, Integer, default: 100, in: (1..100)

              {
                "#{resource.plural}" => resource.paginate(params[:per_page], (params[:page] - 1) * params[:per_page]),
                page: params[:page],
                total: resource.count
              }.to_json
            else
              param :limit, Integer, default: 100, in: (1..100)
              param :offset, Integer, default: 0, min: 0

              {
                "#{resource.plural}" => resource.paginate(params[:limit], params[:offset])
              }.to_json
            end
          end

          get "/#{resource.plural}/:id/?" do
            record = resource[params[:id]] or halt 404
            {entity.name.downcase => record}.to_json
          end
        end if @actions.include?(:read)

        @app.instance_eval do
          put "/#{resource.plural}/:id/?" do
            record = resource[params[:id]] or halt 404
            if record.update!(params)
              status 200
              {entity.name.downcase => record}.to_json
            else
              status 406
              {errors: record.errors}.to_json
            end
          end
        end if @actions.include?(:update)

        @app.instance_eval do
          delete "/#{resource.plural}/:id/?" do
            record = resource[params[:id]] or halt 404
            if record.destroy
              status 200
            else
              status 406
              {errors: record.errors}.to_json
            end
          end
        end if @actions.include?(:delete)

        # @app.instance_eval do
        #   entity.relationships.each do |relationship|
        #     next unless relationship.to_many?

        #     get "/#{resource.plural}/:id/#{relationship.name}/?" do
        #       {relationship.name => resource[params[:id]].send(relationship.name)}.to_json
        #     end
        #   end
        # end
      end
    end

    def call(env)
      @app.call(env)
    end
  end

  module Models
  end
end
