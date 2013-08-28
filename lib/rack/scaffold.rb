require 'rack'
require 'rack/contrib'
require 'sinatra/base'
require 'sinatra/param'
require 'sinatra/multi_route'

require 'rack/scaffold/adapters'

require 'pathname'

module Rack
  class Scaffold
    ACTIONS = [:subscribe, :create, :read, :update, :destroy]

    def initialize(options = {})
      raise ArgumentError, "Missing option: :model or :models" unless options[:model] or options[:models]

      if options[:models] and options[:models].kind_of?(Array)
        @app = Rack::Cascade.new(options.delete(:models).collect{|model| self.class.new(options.dup.merge({model: model}))}) and return
      end

      @app = Class.new(Sinatra::Base) do
        use Rack::PostBodyContentTypeParser
        register Sinatra::MultiRoute
        helpers Sinatra::Param

        before do
          content_type :json
        end

        disable :raise_errors, :show_exceptions

        def last_modified_time(resource, resources)
          update_timestamp_field = resource.update_timestamp_field.to_sym
          most_recently_updated = resources.class.include?(Enumerable) ? resources.max_by(&update_timestamp_field) : resources

          timestamp = request.env['HTTP_IF_MODIFIED_SINCE']
          timestamp = most_recently_updated.send(update_timestamp_field) if most_recently_updated
          timestamp
        end

        def notify!(record)
          return unless @@connections
          
          pathname = Pathname.new(request.path)

          lines = []
          lines << "event: patch"

          op = case status
               when 201 then :add
               when 204 then :remove
               else
                 :update
               end

          data = [{op: op, path: record.url, value: record}].to_json

          @@connections[pathname.dirname].each do |out|
            out << "event: patch\ndata: #{data}\n\n"
          end
        end
      end

      @actions = (options[:only] || ACTIONS) - (options[:except] || [])

      @adapter = Rack::Scaffold.adapters.detect{|adapter| adapter === options[:model]}
      raise "No suitable adapters found for #{options[:model]} in #{Rack::Scaffold.adapters}" unless @adapter

      resources = Array(@adapter.resources(options[:model], options))
      resources.each do |resource|
        @app.instance_eval do
          @@connections = Hash.new([])

          route :get, :subscribe, "/#{resource.plural}/?" do
            pass unless request.accept? 'text/event-stream'

            content_type 'text/event-stream'

            stream :keep_open do |out|
              @@connections[request.path] << out

              out.callback do
                @@connections[request.path].delete(out)
              end
            end
          end
        end if @actions.include?(:subscribe)

        @app.instance_eval do
          post "/#{resource.plural}/?" do
            if record = resource.create!(params)
              status 201
              notify!(record)
              {"#{resource.singular}" => record}.to_json
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

              resources = resource.paginate(params[:per_page], (params[:page] - 1) * params[:per_page])
              last_modified(last_modified_time(resource, resources)) if resource.timestamps?

              {
                "#{resource.plural}" => resources,
                page: params[:page],
                total: resource.count
              }.to_json
            else
              param :limit, Integer, default: 100, in: (1..100)
              param :offset, Integer, default: 0, min: 0

              resources = resource.paginate(params[:limit], params[:offset])
              last_modified(last_modified_time(resource, resources)) if resource.timestamps?

              {
                "#{resource.plural}" => resources
              }.to_json
            end
          end

          get "/#{resource.plural}/:id/?" do
            record = resource[params[:id]] or halt 404
            last_modified(last_modified_time(resource, record)) if resource.timestamps?
            {"#{resource.singular}" => record}.to_json
          end

          resource.one_to_many_associations.each do |association|
            get "/#{resource.plural}/:id/#{association}/?" do
              if params[:page] or params[:per_page]
                param :page, Integer, default: 1, min: 1
                param :per_page, Integer, default: 100, in: (1..100)

                resources = resource.send(association).paginate(params[:per_page], (params[:page] - 1) * params[:per_page])

                {
                  "#{association}" => resources,
                  page: params[:page],
                  total: resource.count
                }.to_json
              else
                param :limit, Integer, default: 100, in: (1..100)
                param :offset, Integer, default: 0, min: 0

                resources = resource.paginate(params[:limit], params[:offset])

                {
                  "#{association}" => resources
                }.to_json
              end
            end
          end          
        end if @actions.include?(:read)

        @app.instance_eval do
          route :put, :patch, "/#{resource.plural}/:id/?" do
            record = resource[params[:id]] or halt 404
            if record.update!(params)
              status 200
              notify!(record)
              {"#{resource.singular}" => record}.to_json
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
              status 204
              notify!(record)
            else
              status 406
              {errors: record.errors}.to_json
            end
          end
        end if @actions.include?(:destroy)
      end
    end

    def call(env)
      @app.call(env)
    end
  end

  module Models
  end
end
