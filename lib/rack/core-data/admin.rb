require 'coffee-script'
require 'eco'
require 'sass'
require 'compass'
require 'bootstrap-sass'
require 'sprockets'
require 'sprockets-sass'

module Rack
  class CoreData::Admin < Sinatra::Base
    use Rack::Static, urls: ['/images'], root: ::File.join(root, "assets")

    set :root, ::File.dirname(__FILE__)
    set :views, Proc.new { ::File.join(root, "assets/views") }
    
    set :assets, Sprockets::Environment.new(::File.join(settings.root, "assets"))
    settings.assets.append_path "javascripts"
    settings.assets.append_path "stylesheets"

    before do
      content_type :json
    end

    get "/javascripts/:file.js" do
      content_type "application/javascript"

      settings.assets["#{params[:file]}.js"]
    end

    get "/stylesheets/:file.css" do
      content_type "text/css"

      settings.assets["#{params[:file]}.css"]
    end

    get '*' do
      content_type :html

      haml :index
    end
  end
end
