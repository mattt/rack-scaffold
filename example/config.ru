require 'sequel'
require 'core_data'
require 'rack/scaffold'

DB = Sequel.connect(ENV['DATABASE_URL'])

STDOUT.sync = true

run Rack::Scaffold.new model: './Example.xcdatamodeld'#, only: [:subscribe, :create, :read]
