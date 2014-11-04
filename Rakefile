require 'bundler/gem_tasks'

desc 'Build Gem'
task :build do
  system 'gem build automation_object.gemspec'
end

desc 'Install Gem'
task :install => :build do
  system "gem install ./automation_object-#{AutomationObject::VERSION}.gem"
end

desc 'Release Gem'
task :release => :build do
  #system "gem push automation_object-#{AutomationObject::VERSION}"
end