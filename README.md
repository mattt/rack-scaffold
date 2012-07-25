# Rack::CoreData
**Automatically generate REST APIs for Core Data models**

> This is still in early stages of development, so proceed with caution when using this in a production application. Any bug reports, feature requests, or general feedback at this point would be greatly appreciated.

<table>
  <thead><tr>
    <th>Core Data Model</th>
    <th>API Endpoints</th>
  </tr></thead>
  <tbody><tr>
    <td><img src="http://heroku-mattt.s3.amazonaws.com/core-data-diagram.png"/></td>
    <td><ul>
      <li><tt>GET /artists</tt></li>
      <li><tt>POST /artists</tt></li>
      <li><tt>GET /artists/1</tt></li>
      <li><tt>PUT /artists/1</tt></li>
      <li><tt>DELETE /artists/1</tt></li>
      <li><tt>GET /artists/1/songs</tt></li> 
    </ul></td>
  </tr></tbody>
</table>

Building web services for iOS apps is a constant struggle to coordinating data models. You're _probably_ not running Objective-C on the server, so you're stuck duplicating your business logic--allthewhile doing your best to maintain the correct conventions and idioms for each platform.

`Rack::CoreData` aims to bridge the client/server divide, and save you time.

Simply point `Rack::CoreData` at your Core Data model file, and a RESTful webservice is automatically created for you, with all of the resource endpoints you might expect in Rails. And since we're running on Rack, each endpoint can be overriden if you need to add or change any existing behavior. Likewise, any of the models can be re-opened to make any necessary adjustments.

**Think of it like an API scaffold: while you may throw all of it away eventually, having something to start with will allow you to iterate on the most important parts of your application while you're the most excited about them.**

## Usage

### Gemfile

```Ruby
$ gem 'rack-core-data', :require => 'rack/core-data' 
```

### config.ru

```ruby
require 'bundler'
Bundler.require

# Rack::CoreData requires a Sequel connection to a database
DB = Sequel.connect(ENV['DATABASE_URL'] || "postgres://localhost:5432/coredata")

run Rack::CoreData('./Example.xcdatamodeld')
```

## Examples

An example web API using a Core Data model can be found the `/example` directory. 

It uses the same data model as the [AFIncrementalStore](https://github.com/afnetworking/afincrementalStore/) example iOS project, so try running that against Rack::CoreData running on localhost.

## Contact

Mattt Thompson

- http://github.com/mattt
- http://twitter.com/mattt
- m@mattt.me

## License

Rack::CoreData is available under the MIT license. See the LICENSE file for more info.
