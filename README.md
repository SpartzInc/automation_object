## AutomationObject Framework for UI Automation (Ruby)

YAML Configuration Based DSL Framework for UI automation (Selenium/Appium)

Use YAML configurations to build blue prints of your app or website.  Define what
screens, elements, relationships exist in the configurations which can then be used as
a DSL framework to interact with the website or app.

### Features

1. Use YAML configuration files to represent UI of an App/Website
2. Add all kinds of relationships between screens and elements for DSL framework
3. Control waiting and sleeping conditions on screen/element interactions for smarter UI testing
3. Use DSL framework to control UI interactions
4. Ability to version UI representation for DRY UI test development

### Fair Warning

This project is still very much a work in progress.  I wanted to get a proof of concept in first before writing
a decoupled complete version.  Right now, many of the objects are coupled tightly which can have some unforeseen issues.
We will try to get a decoupled version out by Jan/Feb 2015.  This gem does work well for our purposes, but I wanted
to warn you beforehand so I wasn't making empty promises.

### Installation

Add this line to your application's Gemfile:

    gem 'automation_object'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install automation_object

### Usage

__[Documentation on AutomationObject](docs/README.md)__ contains all examples and usage of the AutomationObject.

### Contributing

1. Fork it ( https://github.com/mikeblatter/automation_object/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request