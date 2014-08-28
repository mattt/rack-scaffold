require 'sequel'
require 'core_data'
require 'rack/scaffold'

STDOUT.sync = true

DB = Sequel.connect(ENV['DATABASE_URL'])

run Rack::Scaffold.new model: './Example.xcdatamodeld', only: [:create, :read]
