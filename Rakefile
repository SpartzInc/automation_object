require 'bundler/gem_tasks'
require 'fileutils'

desc 'Build Gem'
task :build do
  system 'gem build automation_object.gemspec'
  remove_gem_path = File.join(File.expand_path(File.dirname(__FILE__)), "automation_object-#{AutomationObject::VERSION}.gem")
  FileUtils.rm(remove_gem_path)
end

desc 'Install Gem'
task :install => :build do
  system "gem install ./pkg/automation_object-#{AutomationObject::VERSION}.gem"
end

desc 'Release Gem'
task :release => :build do
  system "gem push ./pkg/automation_object-#{AutomationObject::VERSION}.gem"
end