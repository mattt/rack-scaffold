require 'sequel'
require 'core_data'
require 'rack/scaffold'

DB = Sequel.connect(ENV['DATABASE_URL'])

run Rack::Scaffold.new model: './Example.xcdatamodeld', only: [:create, :read]
