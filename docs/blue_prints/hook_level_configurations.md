Hook Level Configurations
----

This document will cover the available keys and values that may be used at the hook level.  When you define the before hook
it will run the hook right before the method is called.  When you define the after hook, the hook will run right after
the method has been called, but before the DSL framework returns.

**Important Note**:  When defining the following keys, they will be run in the order you set the in.

Example (Click that opens new window and adds a screen):
```
default_screen: 'home_screen'
screens:
  home_screen:
    elements:
      new_window_button:
        css: '#new_window_button'
        click: #element method hook
          after:
            wait_for_new_window: true #Runs before change_screen
            change_screen: 'new_window_screen' #Use for changing screens and adding
  new_window_screen:
    before_load: #Run before the screen is completely loaded
      wait_for_elements:
        - element_name: 'close_window_button'
          exists?: true
          text: 'Close Window Button'
    elements:
      close_window_button:
        click:
          before: #Before hook
            sleep: 1
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

Also modals must have live? configurations defined underneath them so the framework can figure out whether or not they are
appearing.

__Description__:

I only really use this for ads/sign up prompts that might pop up randomly on the site I am trying to automate.
Either include the action close or the modal will be active when you get the screen returned to you.

Only has one possible action 'close'.  Don't really have any other purpose then to close it automatically.  Might add
more to this in the future but can't really think of any other implementations.

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
screens:
  home_screen:
    automatic_onload_modals: #Will also check if modals are alive in the order you put them in here
      - modal_name: 'stupid_ad_modal'
        number_of_checks: 1 #Check if its live? once only
        action: 'close'
      - modal_name: 'second_stupid_ad_modal'
        number_of_checks: 2
        action: 'close'
    modals:
      stupid_ad_modal:
        live?:
          elements:
            - element_name: 'modal_div'
              exists?: true
              visible?: true
            - element_name: 'close_button'
              exists?: true
              visible?: true
        elements:
          modal_div:
            css: '#modal_ad_div'
          close_button:
            css: '#modal_ad_div #close_button'
      second_stupid_ad_modal:
        live?:
          elements:
            - element_name: 'modal_div'
              exists?: true
              visible?: true
        elements:
          modal_div:
            css: '#second_modal_ad_div'
          close_button:
            css: '#second_modal_ad_div #close_button'
```

### change_screen:

__Expecting__: String

__Requirements__:  Value is a screen that is defined in the blue prints.

__Description__:  Use this when a given action will change the screen or add a screen in case it opens a new window.
This is pretty much how you link all the screens together in the automation framework.

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
screens:
  home_screen:
    new_window_button:
      css: '#new_window_button'
      click:
        after:
          wait_for_new_window: true
          change_screen: 'new_window_screen'
    list_links:
      xpath: '//a'
      multiple: true
      click:
        after:
          change_screen: 'list_screen'
  list_screen:
     elements:
       #And so on
  new_window_screen:
     elements:
       #And so on
```

### change_to_previous_screen:

__Expecting__: TrueClass

__Requirements__: Only expects true otherwise don't define in hook.

__Description__:  You can use this when you know a certain action will cause the screen to change to the previous
but the previous screen may be variable.

This will probably come up more in apps then it will on the web (i.e. hamburger menu screen).

__Example (App example, no base url, only xpaths)__:
```
default_screen: 'home_screen'
screens:
  home_screen:
    elements:
      menu_button:
        xpath: '//UIAApplication[1]/UIAWindow[2]/UIAButton[@name="menu_button"]'
        click:
          after:
            change_screen: 'menu_screen'
      list_buttons:
        multiple: true
        css: '//UIAApplication[1]/UIAWindow[2]/UIATableView[1]/UIATableGroup[1]/UIAButton'
        click:
          after:
            change_screen: 'list_screen'
  list_screen:
    elements:
      menu_button:
        xpath: '//UIAApplication[1]/UIAWindow[2]/UIAButton[@name="menu_button"]'
        click:
          after:
            change_screen: 'menu_screen'
  menu_screen:
    elements:
      menu_button:
        xpath: '//UIAApplication[1]/UIAWindow[2]/UIAButton[@name="menu_button"]'
        click:
          after:
            change_to_previous_screen: true
```

### close_modal:

__Expecting__: TrueClass

__Requirements__: Only expects true otherwise don't define in hook.  Define this hook only within modals.

__Description__: Use this when you expect an action to close a modal.

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
screens:
  home_screen:
    modals:
      login_modal:
        username_field:
          css: '#username'
        password_field:
          css: '#password'
          #Changing up the click event for submit, ie automation_object.home_screen.password_field.submit
          #Can bind to any element methods
          submit:
            after:
              close_modal: true
    elements:
      login_button:
        css: '#login_button'
        click:
          after:
            show_modal: 'login_modal'
```

### close_window:

__Expecting__: TrueClass

__Requirements__: Only expects true otherwise don't define in hook.  Only can be used for web automation, not apps.
Since apps do not have multiple windows, framework will not worry about window handles.

__Description__:  Use this when you expect an action to close a window.  Framework will wait for the window handles
to decrease by one and remove the screen from being active.

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
screens:
  home_screen:
    elements:
      new_window_button:
        click:
          after:
            wait_for_new_window: true
            change_screen: 'new_window_screen'
  new_window_screen:
    elements:
      close_window_button:
        click:
          after:
            close_window: true
```

### possible_screen_changes:

__Expecting__: Array

__Requirements__: Expects an Array of defined screens which an action might lead to.

__Description__:  Use this when trying to test multiple paths (happy/unhappy) such as login forms when
typing in the wrong username/password combination.

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'login_screen'
screens:
  login_screen:
    elements:
      username_field:
        css: '#username'
      password_field:
        xpath: '//input[@type="password"]'
        submit:
          after:
            possible_screen_changes:
              - 'login_screen'
              - 'logged_in_screen'
  logged_in_screen:
  #And so on
```

### show_modal:

__Expecting__: String

__Requirements__: Expects a value to be a defined modal within the same screen.

__Description__:  Use when you expect an action to show a modal.

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
screens:
  home_screen:
    modals:
      login_modal:
        before_load:
          wait_for_elements:
            - element_name: 'username_field'
              exists?: true
              visible?: true
        elements:
          username_field:
            css: '#username'
          password_field:
            css: '#pass'
    elements:
      login_button:
        click:
          after:
            show_modal: 'login_modal'
```

### sleep:

__Expecting__: Numeric

__Requirements__: For use only when necessary or when starting out.  Makes tests more brittle than using hooks
to transfer between screens, elements, etc...

__Description__:  Will sleep for a period of time when defined in a hook before continuing the hook.

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
screens:
  home_screen:
    before_load:
      sleep: 1
    live?: #Need to define elements for live, checks to make sure screen is actually live
      before:
        sleep: 4
      elements:
        - element_name: 'login_button'
          exists?: true
    elements:
      login_button:
        css: '#login_button'
        click:
          before:
            sleep: 1
          after:
            sleep: 5
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