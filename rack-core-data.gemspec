# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rack/core-data"

Gem::Specification.new do |s|
  s.name        = "rack-core-data"
  s.authors     = ["Mattt Thompson"]
  s.email       = "m@mattt.me"
  s.homepage    = "http://mattt.me"
  s.version     = Rack::CoreData::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Rack::CoreData"
  s.description = "Automatically generate REST APIs for Core Data models."

  s.add_development_dependency "rspec", "~> 0.6.1"
  s.add_development_dependency "rake",  "~> 0.9.2"

  s.add_dependency "rack", "~> 1.4"
  s.add_dependency "nokogiri", "~> 1.4"
  s.add_dependency "sinatra", "~> 1.3.2"
  s.add_dependency "sequel", "~> 3.37.0"
  s.add_dependency "activesupport", "~> 3.2.6"

  s.files         = Dir["./**/*"].reject { |file| file =~ /\.\/(bin|example|log|pkg|script|spec|test|vendor)/ }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
