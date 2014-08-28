require "rubygems"
require "bundler/setup"

require "rack"
require "rack/test"
require "rspec"

require "sqlite3"
require "sequel"
require "core_data"
require "rack/scaffold"

require "database_cleaner"

DB = Sequel.sqlite

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.color = true

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
