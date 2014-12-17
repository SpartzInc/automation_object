## AutomationObject Framework for UI Automation (Ruby)

YAML Configuration Based Dynamic DSL Framework for UI automation (Selenium/Appium)

Allow usage of YAML configuration files to define the UI of your app or website you wish to automate.  The configurations
(blue prints) in turn help create a dynamic DSL framework that allows you to automate your app/website.  You can define
screens, modals, elements, and hooks which help you effectively automate while keeping your code DRY.

### Features

1. Use YAML configuration files to represent UI of an App/Website
2. Add all kinds of relationships between screens and elements for DSL framework
3. Control waiting and sleeping conditions on screen/element interactions using hooks for less brittle UI testing
3. Use DSL framework to effectively control your automation
4. Ability to version UI representation in YAML files for DRY UI test development

### Fair Warning

This is the initial release of this project, kind of a proof of concept.  It is very coupled/very long internal methods(sorry) but stable.
I plan creating a skeleton framework with proper unit testing and patterns implemented.  Will be creating a separate project
for that, which will then be merged into this project.  If you are interested in having input or helping with that let me know
will probably keep it private unless people want to contribute to that effort.  Goal end date for that will be Jan/Feb 2015
which then I will upgrade the automation_object gem to 1.0.

I will also hold off on making large changes/updates until the 1.0 version is in place.  Will make small updates
here and there to fix bugs.

Past all of this self-deprecation, this gem does work very well for our company's automation testing and has
improved our productivity and testing stability greatly.

### Usage

__[Documentation on AutomationObject](docs/README.md)__ contains all examples and usage of the AutomationObject.

### Installation

Add this line to your application's Gemfile:

    gem 'automation_object'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install automation_object

### Contributing

1. Fork it ( https://github.com/mikeblatter/automation_object/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request