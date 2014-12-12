Hook Level Configurations
----

This document will cover the available keys and values that may be used at the hook level.

**Important Note**:  When defining the following keys, they will be run in the order you set the in.

Example (Click that opens new window and adds a screen):
```
home_screen:
  elements:
    new_window_button:
     css: '#new_window_button'
     click:
       after:
         wait_for_new_window: true
         change_screen: 'new_window_screen' #Use for changing screens and adding
new_window_screen:
  before_load:
    wait_for_elements:
      - element_name: 'close_window_button'
        exists?: true
        text: 'Close Window Button'
  elements:
    close_window_button:
      click:
        after:
          close_window: true
```

### Table of Contents:
*    [automatic_onload_modals](#automatic_onload_modals)
*    [change_screen](#change_screen)
*    [change_to_previous_screen](#change_to_previous_screen)
*    [close_modal](#close_modal)
*    [close_window](#close_window)
*    [possible_screen_changes](#possible_screen_changes)
*    [show_modal](#show_modal)
*    [sleep](#sleep)
*    [reset_screen](#reset_screen)
*    [wait_for_new_window](#wait_for_new_window)

***

### automatic_onload_modals:

__Expecting__: String

__Requirements__:

__Description__:

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
```

### change_screen:

__Expecting__: String

__Requirements__:

__Description__:

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
```

### change_to_previous_screen:

__Expecting__: String

__Requirements__:

__Description__:

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
```

### close_modal:

__Expecting__: String

__Requirements__:

__Description__:

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
```

### close_window:

__Expecting__: String

__Requirements__:

__Description__:

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
```

### possible_screen_changes:

__Expecting__: String

__Requirements__:

__Description__:

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
```

### show_modal:

__Expecting__: String

__Requirements__:

__Description__:

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
```

### sleep:

__Expecting__: String

__Requirements__:

__Description__:

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
```

### reset_screen:

__Expecting__: String

__Requirements__:

__Description__:

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
```

### wait_for_new_window:

__Expecting__: String

__Requirements__:

__Description__:

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
```
---