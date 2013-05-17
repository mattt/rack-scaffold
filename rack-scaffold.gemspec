# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "rack-scaffold"
  s.authors     = ["Mattt Thompson"]
  s.email       = "m@mattt.me"
  s.homepage    = "http://mattt.me"
  s.license     = "MIT"
  s.version     = "0.0.2"
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Rack::Scaffold"
  s.description = "Automatically generate RESTful CRUD services"

  s.add_dependency "rack", "~> 1.4"
  s.add_dependency "rack-contrib", "~> 1.1"
  s.add_dependency "sinatra", "~> 1.3"
  s.add_dependency "sinatra-param", "~> 0.1"
  s.add_dependency "activesupport", ">= 3.0"

  s.add_development_dependency "rake"

  s.files         = Dir["./**/*"].reject { |file| file =~ /\.\/(bin|example|log|pkg|script|spec|test|vendor)/ }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
