# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'automation_object/version'

Gem::Specification.new do |spec|
  spec.name = 'automation_object'
  spec.version = AutomationObject::VERSION
  spec.authors = ['Michael Blatter']
  spec.email = ['mblatter@spartzinc.com']
  spec.summary = %q{YAML configuration based dynamic DSL framework for UI automation using Selenium or Appium drivers.}
  spec.description = %q{This gem provides a way to create a dynamic usable DSL framework representing your website or app.
Implementing Selenium/Appium driver and YAML configurations, this API will provide a layer in between your automation code and the driver.
By creating YAML configurations that represents your website/app, the DSL framework in turn will reflect your configuration
and allow you to control the automation through the DSL framework.  Using this gem can help remove tedious tasks that are often
repeated throughout code and help improve the scalability of code by mapping UI in YAML configuration files.}
  spec.homepage = 'https://github.com/spartzoss/automation_object'
  spec.license = 'MIT'

  #spec.files = `git ls-files -z`.split("\x0")
  spec.files = Dir.glob("{lib}/**/*")
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(docs|test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 0'

  spec.add_runtime_dependency 'colorize', '~> 0.6', '>= 0.6.0'
  spec.add_runtime_dependency 'awesome_print', '~> 1.2', '>= 1.2.0'
  spec.add_runtime_dependency 'thread', '~> 0.1', '>= 0.1.4'
  spec.add_runtime_dependency 'event_emitter', '~> 0.2', '>= 0.2.5'

  spec.add_runtime_dependency 'rspec', '~> 3.1.0', '>= 3.1.0'
  spec.add_runtime_dependency 'rspec-expectations', '~> 3.1', '>= 3.1.2'

  spec.add_runtime_dependency 'appium_lib', '~> 4.1', '>= 4.1.0'
  spec.add_runtime_dependency 'selenium-webdriver', '~> 2.44', '>= 2.44.0'
end