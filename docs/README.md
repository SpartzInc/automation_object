AutomationObject Framework README
----

### Table of Contents:
*    [Putting it together](#putting-it-together)
*    [Blue Print Documentation](#blue-print-documentation)
*    [Framework Documentation](#framework-documentation)
*    [Examples](#examples)

### Putting it together

AutomationObject Framework allows you to create YAML configurations to define UI on a website or app.
You will put all YAML files into a single folder to represent one website/app version.  YAML files are just combined
into one large Hash object.

Code for getting YAML configurations and converting into one single blueprint:
```
require 'automation_object'

#Set base directory so you don't have to specify full folder path each time
AutomationObject::BluePrint::base_directory = '/base/blue_print/directory'

#Returns merged Hash
blue_prints = AutomationObject::BluePrint.new('/path/to/specific/blueprints')
```

Then you will take the merged Hash file and input the Selenium or Appium driver into AutomationObject::Framework:
```
#...continued from above
driver = Selenium::WebDriver.for :chrome
automation_object = AutomationObject::Framework.new(driver, blue_prints)

#purely hypothetical possible usage of automation_object variable
automation_object.home_screen.search_button.click
automation_object.search_screen.search_input.send_keys('looking for something')
automation_object.search_screen.search_button.click
```

As you can see from the small hypothetical example above, you can define screens, elements in YAML configurations and
work with the elements through AutomationObject::Framework instance.

Here is the combined simple YAML configuration for the hypothetical example above:
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


### Blue Print Documentation
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

- [Simple example](examples/simple)
  - Small example to get your feet wet
- [Android example](examples/android)
  - Android example to show you how to use Appium, Android, and AutomationObject
- [iOS example](examples/ios)
  - iOS example to show you how to use Appium, iOS, and AutomationObject
- [Debugging example](examples/debugging)
  - Shows how to use debugging to figure out what might have gone wrong
- [Views example](examples/views)
  - Shows how to use views, which help reduce the size of blue prints
- [Elements example](examples/elements)
  - Shows the different types of configurations of elements available and how to use them
- [Hooks example](examples/hooks)
  - Shows how to include hooks into framework events to create stable tests
- [iFrames example](examples/iframes)
  - Shows how to implement iframe interactions
- [Modals example](examples/modals)
  - Shows how to use modals, which can be used for dropdowns and other popups that may occur with interactions
- [Multiple windows example](examples/multiple_windows)
  - Demonstrates how multiple windows are handled within the framework
- [No default screen example](examples/no_default_screen)
  - Sometimes sites/apps don't have a default screen.  This shows you how to implement that in blue prints
- [Automatic screen routing example](examples/automatic_screen_routing)
  - Shows how to use automatic screen routing, which will transfer to screens automatically when calling screens that are not
  currently live.
- [Automatic screen changes example](examples/automatic_screen_changes)
  - Shows how to implement automatic screen changes and what use cases this may be required
- [Automatic onload modals example](examples/automatic_onload_modals)
  - Shows how to implement automatic onload modals.  This is mainly to get rid of ads or other random modals that may occur on certain
  screens.
- [Throttle Driver Interactions](examples/throttle_driver_interactions)
  - If you are having issues with browsers/apps/drivers crashing, then throttling may help stabilize tests.
  This example will show you how to throttle driver and element interactions