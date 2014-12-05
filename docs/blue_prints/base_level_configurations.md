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

#### element_name:

__Class__: String

__Description__:

Should match up to an element defined in the same screen.

__Example__:
```
screens:
  home_screen:
    before_load:
      - element_name: 'example_button'
        exists?: true
    elements:
      example_button:
        xpath: '//xpath'
```

---


