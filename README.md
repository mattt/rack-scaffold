# Rack::Scaffold
**Automatically generate RESTful CRUD services**

> This project generalizes the webservice auto-generation functionality of [Rack::CoreData](https://github.com/mattt/rack-core-data) with a plugin architecture that can adapt to any data model format. It is currently being actively developed for inclusion in the next release of [Helios](https://github.com/helios-framework/helios)

### Supported Data Models

- [Core Data Model](https://github.com/mattt/core_data/) (`.xcdatamodeld`)
- [Sequel](https://github.com/jeremyevans/sequel)
- [ActiveRecord](https://github.com/rails/rails)

## Usage

### Gemfile

```Ruby
source :rubygems

gem 'rack-scaffold', require: 'rack/scaffold'
gem 'sequel'
gem 'core_data'

gem 'unicorn'
gem 'pg'
```

### config.ru

```ruby
require 'sequel'
require 'core_data'
require 'rack/scaffold'

DB = Sequel.connect(ENV['DATABASE_URL'])

run Rack::Scaffold model: './Example.xcdatamodeld', only: [:create, :read]
```

## Examples

An example web API using a Core Data model can be found the `/example` directory.

## Contact

Mattt Thompson

- http://github.com/mattt
- http://twitter.com/mattt
- m@mattt.me

## License

Rack::Scaffold is available under the MIT license. See the LICENSE file for more info.
