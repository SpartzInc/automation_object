AutomationObject Framework README
----

Table of Contents:
*    [Putting it together](#putting-it-together)
*    [Blue Prints](#blue-prints)
*    [Framework Methods](#framework-methods)
*    [Examples](#examples)

### Putting it together

AutomationObject Framework allows you to create YAML configurations to define UI on a website or app.
You will put all YAML files into a single folder to represent one website/app version.  YAML files are just combined
into one large Hash variable.

Code for getting YAML configurations and converting into one single blueprint:
```
require 'automation_object'

#Set base directory so you don't have to specify full folder path each time
AutomationObject::base_directory = '/base/blue_print/directory'
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


### Blue Prints

### Framework Methods

### Examples

- [Simple demonstration](examples/simple)
  - Small example to get your feet wet
- [Debugging demonstration](examples/debugging)
  - Shows how to use debugging to figure out what might have gone wrong
- [Views demonstration](examples/views)
  - Shows how to use views, which help reduce the size of blue prints
- [Elements demonstration](examples/elements)
  - Shows the different types of configurations of elements available on how to use them
- [Hooks demonstration](examples/hooks)
  - Shows how to include hooks into framework events to create stable tests
- [iFrames demonstration](examples/iframes)
  - Shows how to use iframes
- [Modals demonstration](examples/modals)
- [Multiple windows demonstration](examples/multiple_windows)
- [No default screen demonstration](examples/no_default_screen)
- [Automatic screen routing demonstration](examples/automatic_screen_routing)
- [Automatic screen changes demonstration](examples/automatic_screen_changes)
- [Automatic onload modals demonstration](examples/automatic_onload_modals)