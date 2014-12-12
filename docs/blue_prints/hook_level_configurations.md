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

__Expecting__: Array

__Requirements__: For use only in before_load under screens.  Will check for any modals that might automatically appear.
Only really use this for ads that might pop up on the site I am trying to automate.  Either include the action close or
the modal will be active when you get the screen returned to you.

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

__Expecting__: TrueClass

__Requirements__: Only expects true otherwise don't define in hook.

__Description__:

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
```

### close_modal:

__Expecting__: TrueClass

__Requirements__: Only expects true otherwise don't define in hook.

__Description__:

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
```

### close_window:

__Expecting__: TrueClass

__Requirements__: Only expects true otherwise don't define in hook.  Only can be used for web automation, not apps.
Since apps do not have multiple windows, framework will not worry about window handles.

__Description__:

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
screens:
  home_screen:
    new_window_button:
      click:
        after:
          wait_for_new_window: true
          change_screen: 'new_window_screen'
  new_window_screen:
    close_window_button:
      click:
        after:
          close_window: true
```

### possible_screen_changes:

__Expecting__: Array

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

__Expecting__: Numeric

__Requirements__:

__Description__:

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
```

### reset_screen:

__Expecting__: TrueClass

__Requirements__: Only expects true otherwise don't define in hook.

__Description__:  When you have actions on a screen that may cause many things to change, elements to removed/added
back in, and other such shenanigans that may occur.  This will reset any stored elements, element hashes, element arrays,
or element groups.  So when you try to access those elements again they will be properly reloaded.

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
screens:
  home_screen:
    elements:
      list_links:
        css: 'a'
        multiple: true
      load_more_links_button:
        css: 'div.load_more'
        click:
          after:
            reset_screen: true
```

### wait_for_new_window:

__Expecting__: TrueClass

__Requirements__:  Only expects true otherwise don't define in hook.  Only can be used for web automation, not apps.
Since apps do not have multiple windows, framework will not worry about window handles.

__Description__: Use this when you expect an action to open a new window.  This hook will then wait for the window
handles on Selenium/Appium to increase by one before performing any other hook actions or returned the new screen.

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
screens:
  home_screen:
    new_window_button:
      click:
        after:
          wait_for_new_window: true
          change_screen: 'new_window_screen'
  new_window_screen:
    close_window_button:
      click:
        after:
          close_window: true
```
---