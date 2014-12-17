Base Level Configurations
----

This document will cover the available keys and values that may be used at the base YAML or Hash level.

### Table of Contents:
*    [base_url](#base_url)
*    [default_screen](#default_screen)
*    [screens](#screens)
*    [screen_transition_sleep](#screen_transition_sleep)
*    [throttle_driver_methods](#throttle_driver_methods)
*    [throttle_element_methods](#throttle_element_methods)
*    [views](#views)

***

### base_url:

__Expecting__: String

__Requirements__: Expecting web browser for either Appium or Selenium, if app it will error out

__Description__:

Base url of the website you want to automate

__Example__:
```
base_url: 'http://www.google.com'
```
---

### default_screen:

__Expecting__: String

__Requirements__: Expecting string defined to be a screen defined under screens. Should always be the initial screen
when starting AutomationObject::Framework

__Description__:

Use if your automation always starts on one screen.  If the initial screen can be different, then don't define
and use live? configurations in screens and the automation framework will figure out which screen you are initially
on.

__Example__:
```
default_screen: 'home_screen'
screens:
  home_screen:
  list_screen:
```

__Example without Default Screen__:
```
base_url: 'http://www.google.com'
screens:
  home_screen:
    live?:
      elements:
        - element_name: 'title_text'
          exists?: true
          text: 'Home Screen'
    elements:
      title_text:
        css: '#title_text'
  list_screen:
    live?:
      elements:
        - element_name: 'title_text'
          exists?: true
          text: 'List Screen'
    elements:
      title_text:
        xpath: '//*[@id="title_text"]'
```
---

### screens:

__Expecting__: Hash

__Description__:

This hash will contain all the defined screens that you will need to automate.

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
screens:
  home_screen:
    elements:
      search_button:
        css: '#search_button'
  search_screen:
    elements:
      title_text:
        css: '#title_text'
  #Add so on
  #Also it's advantageous to split up YAML files by screen to keep maintainable files
```
---

### screen_transition_sleep:

__Expecting__: Numeric

__Default__: 0

__Description__:

Can be used to help build automation configurations at the beginning by adding a sleep every time you change a screen.
When no waiting hooks exist, this will help keep the automation from breaking or raising errors.  Try to use hooks
to make your automation less brittle and faster.

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
screen_transition_sleep: 1
screens:
  home_screen:
  search_screen:
```
---

### throttle_driver_methods:

__Expecting__: Hash

__Description__: If you are having issues when interacting with the driver too quickly, you can throttle driver
methods via this configuration.  Then each method that is called will at the minimum take the time you define before
returning.  Time is defined in seconds.

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
throttle_driver_methods:
  find_element: 5 #In Seconds
  manage: 4
  execute_script: 6.6
  switch_to: 2
  exists?: 3.2
```
---

### throttle_element_methods:

__Expecting__: Hash

__Description__: If you are having issues when interacting with elements too quickly, you can throttle elements
methods via this configuration.  Then each method that is called will at the minimum take the time you define before
returning.  Time is defined in seconds.

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
throttle_element_methods:
  click: 5 #In Seconds
  send_keys: 4
  submit: 6.6
  location: 2
  size: 3.2
```
---

### views:

__Expecting__: Hash

__Description__: Use views when you have commonalities between screens.  This can help keep your configurations DRY
and not have to repeat yourself throughout each YAML file.  Views can have all the same configurations available as
[screens](screen_level_configurations.md).  They are then included into screens using
[included_views](screen_level_configurations.md#included_views).

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
views:
  common_screen_view:
    before_load: #Hook when a screen is loaded
      wait_for_elements:
        - element_name: 'title'
          exists?: true
    elements:
      title:
        css: 'h1#title'
      description:
        css: 'p#description'
screens:
  home_screen:
    included_views:
      - 'common_screen_view'
  search_screen:
    included_views:
      - 'common_screen_view'
```
---