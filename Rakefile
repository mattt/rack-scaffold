require "bundler"
Bundler.setup

gemspec = eval(File.read("rack-scaffold.gemspec"))

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["rack-scaffold.gemspec"] do
  system "gem build rack-scaffold.gemspec"
end
