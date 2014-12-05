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

__Requirements__: Expecting existing screen defined in the blue prints

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
---