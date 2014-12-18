AutomationObject README
----

The documentation has been broken up into a few different parts.  I'll start off with a small example so that you may have
an understanding of what this gem does.  Then there is the blue prints documentation which describes all of the ways you
can set up the YAML configuration files.  The framework documentation shows how you would create and use the dynamic DSL
framework.  Finally there are a bunch of examples at the bottom to show how to implement a variety of features offered
with this gem.

### Table of Contents:
*    [Putting it together](#putting-it-together)
*    [Blue Print Documentation (YAML Configurations)](#blue-print-documentation-yaml-configurations)
*    [Framework Documentation](#framework-documentation)
*    [Examples](#examples)

### Putting it together

This section will show you exactly what this gem does.  It will show how to create YAML files, load those YAML files,
and the creation/usage of the dynamic DSL framework.  The dynamic DSL framework will represent the configurations you
load into it.  Typically you will split of YAML files by screen or view and keep them in the same directory
in order to keep configurations shorter.  You may also include sub-directories into your YAML configuration folder.

__Combined YAML Code for Mapping the UI of a Website or App__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
screens:
  home_screen:
    elements:
      search_button:
        xpath: '//path/to/search/button'
        click:
          after:
            change_screen: 'search_screen'
  search_screen:
    before_load:
      wait_for_elements:
        - element_name: 'search_button'
          exists?: true
    elements:
      search_button:
        css: '#css .path .to .element'
      search_input:
        xpath: '//xpath/to/element'
```

__Ruby Code for Loading and Merging YAML configuration files__:
```
require 'automation_object'
require 'selenium-webdriver'

#Set base directory so you don't have to specify full folder path each time
AutomationObject::BluePrint::base_directory = '/base/blue_print/directory'

#Returns merged Hash object
blue_prints = AutomationObject::BluePrint.new('/path/to/specific/blueprints')
```

__Continued Ruby Code for Creating and Using the DSL Framework__:
```
#...continued from above
driver = Selenium::WebDriver.for :chrome
automation_object = AutomationObject::Framework.new(driver, blue_prints)

#purely hypothetical possible usage of AutomationObject::Framework instance object
automation_object.home_screen.search_button.click
automation_object.search_screen.search_input.send_keys('looking for something')
automation_object.search_screen.search_button.click
```

### Blue Print Documentation (YAML Configurations)
- [Base Level Configurations](blue_prints/base_level_configurations.md)
  - Available base level configurations for blue prints
- [Screen Level Configurations](blue_prints/screen_level_configurations.md)
  - Available screen level configurations for blue prints
- [Element Level Configurations](blue_prints/element_level_keys.md)
  - Available element level configurations for blue prints
- [Hook Level Configurations](blue_prints/hook_level_configurations.md)
  - Available hook level configurations for blue prints
- [Possible YAML File Layout](blue_prints/possible_yaml_file_layout.md)
  - Possible YAML file layout to make your blue prints more organized.

### Framework Documentation

- [Initializing the Framework](framework/initializing_the_framework.md)
  - Shows how you would create a new blue print object and subsequently the framework object.
- [Framework Documentation](framework/framework.md)
  - How to use the framework object
- [Screen Object Documentation](framework/screen_object.md)
  - How to use a screen object, these are dynamically created depending on your configuration, contained in the framework
  object
- [Element Object Documentation](framework/element_object.md)
  - How to use a element object, these are dynamically created depending on your configuration, contained in the
  screen object it was defined in.

### Examples

These examples should help you get a good idea of how to use AutomationObject without all the documentation above.
All of these examples are fairly simple so that you can get an idea of how all the different parts/configurations work.
If you need an example of something, let me know; I will try to get it in here.

- [Simple example](examples/simple)
  - Small example to get your feet wet
- [Android example](examples/android)
  - Android example to show you how to use Appium, Android, and AutomationObject
- [iOS example](examples/ios)
  - iOS example to show you how to use Appium, iOS, and AutomationObject
- [Debugging example](examples/debugging)
  - Shows how to use debugging to figure out what might have gone wrong
- [Elements example](examples/elements)
  - Shows how to use elements, element groups, element hashes, and element arrays.
- [Views example](examples/views)
  - Shows how to use views, which help reduce the size of blue prints
- [Hooks example](examples/hooks)
  - Shows how to include hooks into framework events to create stable tests
  - Demonstrates how multiple windows are handled within the framework
- [Modals example](examples/modals)
  - Shows how to use modals, using the FancyBox jquery plugin as the demo
- [No default screen example](examples/no_default_screen)
  - Sometimes sites/apps don't have a default screen.  This shows you how to implement that in blue prints
- [Automatic screen routing example](examples/automatic_screen_routing)
  - Shows how to use automatic screen routing, which will transfer to screens automatically when calling screens that are not
  currently live.
- [Automatic screen changes example](examples/automatic_screen_changes)
  - Shows how to implement automatic screen changes and what use cases this may be required
- [Throttle Driver Interactions](examples/throttle_driver_interactions)
  - If you are having issues with browsers/apps/drivers crashing, then throttling may help stabilize tests.
  This example will show you how to throttle driver and element interactions