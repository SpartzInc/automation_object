# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'automation_object/version'

Gem::Specification.new do |spec|
  spec.name = 'automation_object'
  spec.version = AutomationObject::VERSION
  spec.authors = ['Michael Blatter']
  spec.email = ['mblatter@spartzinc.com']
  spec.summary = %q{YAML Configuration Based DSL Framework for UI Automation}
  spec.description = %q{}
  spec.homepage = 'https://github.com/mikeblatter/automation_object'
  spec.license = 'MIT'

  #spec.files = `git ls-files -z`.split("\x0")
  spec.files = Dir.glob("{lib}/**/*")
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(docs|test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'bundler', '~> 1.6'
  spec.add_dependency 'rake', '~> 0'

  spec.add_dependency 'colorize', '~> 0.6', '>= 0.6.0'
  spec.add_dependency 'awesome_print', '~> 1.2', '>= 1.2.0'
  spec.add_dependency 'thread', '~> 0.1', '>= 0.1.4'
  spec.add_dependency 'event_emitter', '~> 0.2', '>= 0.2.5'
end
