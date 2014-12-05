Base Level Configurations
----

This document will cover the available keys and values that may be used at the base level.

### Table of Contents:
*    [base_url](#base_url)
*    [default_screen](#default_screen)
*    [screens](#screens)
*    [screen_transition_sleep](#screen_transition_sleep)
*    [throttle_driver_methods](#throttle_driver_methods)
*    [throttle_element_methods](#throttle_element_methods)
*    [views](#views)

***

#### base_url:

__Expecting__: String

__Requirements__: Expecting web broser for Appium or Selenium, if app it will error out

__Description__:

Base url of the website you want to automate

__Example__:
```
base_url: 'http://www.google.com'
```
---

#### default_screen:

__Expecting__: String

__Requirements__: Expecting string defined to be a screen defined under screens

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

#### screens:

__Expecting__: Hash

__Description__:

This hash will contain all the defined screens that you with to automate.

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
  #Also it is advantageous to split up YAML files by screen to help keep a maintainable configuration.
```
---

#### screen_transition_sleep:

__Expecting__: Numeric

__Default__: 0

__Description__:

Can be used to help build automation at the beginning by adding a sleep every time you change a screen.
When no waiting hooks exist this will help keep the automation from breaking or raising errors.

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

#### throttle_driver_methods:

__Expecting__: Hash

__Description__:

__Example__:
```
```
---

#### throttle_element_methods:

__Expecting__: Hash

__Description__:

__Example__:
```
```
---