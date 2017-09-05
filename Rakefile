require 'rubygems'
require 'rack/test'
require 'rake/clean'
require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

task :default => :spec

# output directory - removed with "rake clobber" (needs a "require 'rake/clean'" above)
CLOBBER.include('coverage')

desc 'Open irb or pry session preloaded with lib/'
task :console do
  begin
    require 'pry'
    gem_name = 'thumby'
    sh %(pry -I lib -r #{gem_name}.rb)
  rescue LoadError => _
    sh %(irb -rubygems -I lib -r #{gem_name}.rb)
  end
end
