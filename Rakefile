require "bundler"
Bundler.setup

gemspec = eval(File.read("rack-core-data.gemspec"))

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["rack-core-data.gemspec"] do
  system "gem build rack-core-data.gemspec"
end
