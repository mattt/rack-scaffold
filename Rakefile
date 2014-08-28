require "bundler"
Bundler.setup

require "rspec/core/rake_task"

gemspec = eval(File.read("rack-scaffold.gemspec"))

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["rack-scaffold.gemspec"] do
  system "gem build rack-scaffold.gemspec"
end

RSpec::Core::RakeTask.new(:spec) do |config|
  #config.rcov = true
  config.pattern = "./**/*_spec.rb"
  config.ruby_opts = "-w"
end

desc "Run all the tests"
task :default => :spec

# spec/spec_helper.rb
require 'rspec/autorun'
