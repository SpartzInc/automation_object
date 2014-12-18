## AutomationObject Framework for UI Automation (Ruby Gem)

YAML Configuration Based Dynamic DSL Framework for UI Automation (Selenium/Appium)

This gem provides a way to create a dynamic usable DSL framework representing your website or app. By using a Selenium
or Appium driver and YAML configurations, this API will provide a layer in between your automation code and the driver.
By creating YAML configurations that represents your website/app, the DSL framework in turn will reflect your configuration
and allow you to control the automation through the DSL framework.  Using this gem can help remove tedious tasks that are often
repeated throughout code and help improve the scalability of code by mapping UI in YAML configuration files.

### Features

1. Use YAML configuration files to represent UI of a website or app
2. Add all the UI screens/elements/relationships/hooks needed to create an effective dynamic DSL framework
3. Control waiting and sleeping conditions on screen/element interactions using hooks for less brittle UI testing
4. Use the DSL framework to effectively control your automation
5. Automatically routing between screens, modals, windows, iframes enables less code intensive automation.
6. Enables DRY automation test development by storing UI representations in configuration files instead of code and
keeps the complex automation code internal to the API.

### Fair Warning

This is the initial release of this project, kind of a proof of concept.  It is very coupled/very long internal methods (sorry) but stable.
I plan creating a skeleton framework with proper unit testing and patterns implemented.  Will be creating a separate project
for that, which will then be merged back into this project.  If you are interested in having input or helping with that let me know,
will probably keep it private unless people want to contribute to that effort.  Goal end date for that will be Jan/Feb 2015
which then I will upgrade the automation_object gem to 1.0.

I will also hold off on making large changes/updates until the 1.0 version is in place.  Will make small updates
here and there to fix bugs.

This gem does work very well for our company's automation testing and has improved our productivity and
testing stability greatly.

### Usage

__[Documentation on AutomationObject](docs/README.md)__ contains all the usages and examples of the AutomationObject gem.

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