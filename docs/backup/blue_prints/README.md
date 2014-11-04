AutomationObject Blue Prints Overview
--------
__[Main Overview](../../README.md)__ ->
__[AutomationObject Overview](../README.md)__ ->
Blue Prints Overview

Blue prints are a series of Hashes and are used to create an abstract map of your site/app.
These blue prints describe your automation target, providing the AutomationObject::Framework class
with information needed to create the DSL framework.
Not only do blue prints describe the elements they will also describe the screens (pages), how screens can
change from one to another (maybe automatically?), how elements can alter the current state, and so on.

Blue prints can also be used to correctly wait for events to occur before changing a state.  Such as for an element
to exist before changing a screen and clicking on another element.  This will help stabilize the automation process
and reduce brittleness in your tests.

Blue prints are stored using a set of YAML configuration files grouped together in a directory.

Using the AutomationObject::BluePrint class, you can load configuration files grouped in a single directory
```
require 'automation-object'

blue_prints = AutomationObject::BluePrint.new('/path/to/grouped/yaml/configurations')
puts blue_prints.class #AutomationObject::BluePrint < Hash < Object
```

Methods will be dynamically created on the AutomationObject::Framework < Object that will return various objects
such as Screen, Modal, ElementHash, ElementArray, and Element objects.

This documentation will provide the any and all acceptable keys/values for a possible blue print Hash.

### Example Blue Print

Sample YAML configuration with all base level hash keys included.

```
base_url: 'https://www.google.com'
default_screen: 'home_screen'
throttle_element_interactions:
  click: 1
  exists?: 2
screen_transition_sleep: 1
views:
  header_view:
    elements:
      logo_button:
        xpath: '//xpath/to/logo/button'
screens:
  home_screen:
    included_views:
      - 'header_view'
    elements:
      search_button:
        css: '#css_path_to_button'
```

### Available Base Hash Keys:
*    [base_url](#base_url)
*    [default_screen](#default_screen)
*    [screen_transition_sleep](#screen_transition_sleep)
*    [throttle_element_interactions](#throttle_element_interactions)
*    [views](#views)
*    [screens](#screens)

---
#### base_url:

__Class__: String

__Description__:

On framework initialization will navigate to base_url.
Navigation called by using Selenium::WebDriver::Driver.navigate.to

__Important__:

1. For browser based drivers only

__Example__:
```
base_url: 'https://www.google.com'
````

---

#### default_screen:

__Class__: String

__Description__:

Use this if one screen is always the initial screen or if you have yet to set up any live? screen configurations.
If not set will attempt to check live? screen configurations to figure out which screen the framework is on.

__Important__:

1. Will skip checking live? screen configurations on Framework initialize if this is set.

__Example:__

```
default_screen: 'home_screen'
screens:
    home_screen: #Example, would expect a Hash for this
    search_screen:
````

---

#### screen_transition_sleep:

__Class__: Numeric

__Description__:

Useful for initial setting up of blue prints.
Will allow for more flexible use of elements before better waiting hooks are implemented.
Will call sleep when a screen change has occurred.

__Example__:
```
screen_transition_sleep: 1 #Or 1.1, will do sleep(screen_transition_sleep.to_f)
```
---

#### throttle_element_interactions:

Useful if you have issues with Selenium/Appium crashing. Throttle element interactions measuring in seconds.

Will help slowdown AutomationObject interactions with the UI and lessen impact on the UI server.

Allows for the slowing down of the element interactions by causing any element action called on the framework
to take at least the specified amount of time in seconds.  Will sleep the difference between the given throttle speed
in seconds and the amount of time the driver took given it is larger than zero.

__Important__:

1. If the driver takes longer than the specified throttle speed, no sleep will occur

__Class__: Hash

__Available Keys__:

Any method available on Element object

__Example__:
```
throttle_element_interactions:
  click: 1 #Expecting Numeric
  exists?: 1.1
  visible?: 1.2
```
---

#### [views](views.md):

Views contain any screen configurations that can be used across multiple screens.

__Class__: Hash

__Example__:
```
default_screen: 'home_screen'
screens:
  views:
    header_view:
      elements:
        logo_button:
          css_path: '#path_to_element'
  home_screen:
    included_views:
      - 'header_view'
  search_screen:
    included_views:
      - 'header_view'
    #...And so on...
```
---

#### [screens](screens/README.md):

Screens Hash will contain all the different screens your site/app contain.

__Class__: Hash

__Available Keys__:

Name keys based on the screen name, use lower case, and underscores when describing a screen key.

__Example__:
```
default_screen: 'home_screen'
screens:
  home_screen:
    before_load:
      sleep: 2
    elements: #Including some things that are explained at length in subsequent docs
      search_button:
        xpath: '//xpath/to/element'
        click:
          after:
            change_screen: 'search_screen'
  search_screen:
    #...And so on...
```
---