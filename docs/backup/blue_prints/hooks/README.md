Hooks Overview (before, after, or before_load)
--------
__[Main Overview](../../../README.md)__ ->
__[AutomationObject Overview](../../README.md)__ ->
__[Blue Prints Overview](../README.md)__ ->
Hooks Overview

before, after, before_load (screen specific) all have the same available configuration keys.

These hooks can be used on both screen actions and element actions.

__Important__:

1. Any element references contained in hook must be in the same screen of the hook definition.
2. Will run hook in order of keys as defined in the given hash

### Available Hook Hash Keys:
*    [sleep](#sleep)
*    [wait_for_new_window](#wait_for_new_window)
*    [wait_for_elements](#wait_for_elements)
*    [show_modal](#show_modal)
*    [close_modal](#close_modal)
*    [close_window](#close_window)
*    [change_screen](#change_screen)
*    [change_to_previous_screen](#change_to_previous_screen)

---

#### sleep:

__Class__: Numeric

__Description__:

Will sleep for a specified amount of seconds during the hook in which it is defined.

__Important__:

This is a crutch, use only if you need it.

__Example__:
```
base_url: 'https://www.google.com'
default_screen: 'home_screen'
screens:
  home_screen:
    before_load:
      sleep: 1
    elements:
      search_button:
        xpath: '//xpath/to/element'
        click:
          before:
            sleep: 1
          after:
            sleep: 5
            change_screen: 'search_prompt'
    search_prompt:
      accept:
        before:
          sleep: 1
        after:
          sleep: 1
          change_screen: 'home_screen'
      dismiss:
        before:
          sleep: 1
        after:
          sleep: 1
          change_to_previous_screen: true
```

---

#### wait_for_new_window:

__Class__: Boolean

__Description__:

Expects true as a value and for Browsers only.  Will loop until a new window is created then execute subsequent
defined hooks

__Important__:

Browsers only and needs to be true if defined.

__Example__:
```
base_url: 'https://www.google.com'
default_screen:
screens:
  home_screen:
    elements:
      search_button:
        xpath: '//xpath/to/button'
        click:
          after:
            wait_for_new_window: true
            change_screen: 'new_window_screen'
  new_window_screen:
    elements:
      etc...
```

---

#### [wait_for_elements](wait_for_elements.md):

__Class__: Array

__Description__:

Link above [wait_for_elements](wait_for_elements.md) describes this definition in much more detail.

Expects an Array of Hashes that describe what elements and what element requirements are to meet before
completing a hook.

__Important__:

This is an affective way of controlling UI automation without using brittle sleeps and quickens the rate
at which you can automate.

__Example__:
```
base_url: 'https://www.google.com'
default_screen:
screens:
  home_screen:
    before_load:
      wait_for_elements:
        - element_name: 'search_button'
          exists?: true
          visible?: true
    elements:
      search_button:
        xpath: '//xpath/to/button'
        click:
          after:
            wait_for_elements:
              - element_name: 'loading_gif'
                exists?: false
      loading_gif:
        css: '#css_path_to_imaginary_image'
```

---

#### show_modal:

__Class__: String

__Description__:

Name of the Modal that will be opened when performing an action.

__Important__:

Modal must be defined in the same screen that the hook is defined.

__Example__:
```
default_screen: 'home_screen'
views:
  header_view:
    modals:
      login_modal:
        elements:
          username_input:
            xpath: '//xpath/to/input'
          password_input:
            xpath: '//xpath/to/input'
          login_button:
            xpath: '//xpath/to/input'
            click:
              after:
                close_modal: 'login_modal'
                change_screen: 'user_home_screen'
    elements:
      user_login_button:
        xpath: '//xpath/to/button'
        show_modal: 'login_modal'
screens:
  home_screen:
    included_views:
      - 'header_view'
  user_home_screen:
    logout_modal:
      elements:
        are_use_sure_button:
          xpath: '//xpath'
          click:
            after:
              close_modal: 'logout_modal'
              change_screen: 'home_screen'
    elements:
      logout_button:
        xpath: '//xpath'
        click:
          after:
            show_modal: 'logout_modal'
```

---

#### close_modal:

__Class__: String

__Description__:

Name of the Modal that will be closed when performing an action.

__Important__:

Modal must be defined in the same screen that the hook is defined.

__Example__:
```
default_screen: 'home_screen'
views:
  header_view:
    modals:
      login_modal:
        elements:
          username_input:
            xpath: '//xpath/to/input'
          password_input:
            xpath: '//xpath/to/input'
          login_button:
            xpath: '//xpath/to/input'
            click:
              after:
                close_modal: 'login_modal'
                change_screen: 'user_home_screen'
    elements:
      user_login_button:
        xpath: '//xpath/to/button'
        show_modal: 'login_modal'
screens:
  home_screen:
    included_views:
      - 'header_view'
  user_home_screen:
    logout_modal:
      elements:
        are_use_sure_button:
          xpath: '//xpath'
          click:
            after:
              close_modal: 'logout_modal'
              change_screen: 'home_screen'
    elements:
      logout_button:
        xpath: '//xpath'
        click:
          after:
            show_modal: 'logout_modal'
```

---

#### close_window:

__Class__: Boolean

__Description__:

When an action that is performed closes the window that it is in.  Can occur if you have a pop-up that you would
like to automate and an action on that window will cause the window to open.

Does nothing if you define it as false.

__Important__:

Browsers only, involves using multiple windows

__Example__:
```
default_screen: 'home_screen'
screens:
  home_screen:
    elements:
      facebook_like_button:
        xpath: '//xpath'
        click:
          after:
            change_screen: 'facebook_login_screen' #Opens new window
  facebook_login_screen:
    elements:
      login_button:
        css: '#css'
        click:
          after:
            close_window: true
```

---

#### change_screen:

__Class__: String

__Description__:

Name of the new screen when an action is performed.

__Important__:

Used to describe the relationship between screens.

__Example__:
```
default_screen: 'home_screen'
screens:
  home_screen:
    elements:
      example_element:
        click:
          after:
            change_screen: 'second_screen'
  second_screen:
    elements:
      #And so on...
```

---

#### change_to_previous_screen:

__Class__: Boolean

__Description__:

Occurs when an action causes the screen to change to the previous one.

__Important__:

Used to describe the relationship between screens.

__Example__:
```
default_screen: 'home_screen'
screens:
  home_screen:
    elements:
      example_element:
        click:
          after:
            change_screen: 'second_screen'
  second_screen:
    elements:
      back_button:
        click:
          after:
            change_to_previous_screen: true
```

---

