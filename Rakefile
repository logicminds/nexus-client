require "bundler/gem_tasks"

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec')

task :default => :spec

desc "Build gem"
task :build do
  `gem build nexus_client.gemspec`
end
