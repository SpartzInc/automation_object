Screens Blue Prints Overview
--------
__[Main Overview](../../../README.md)__ ->
__[AutomationObject Overview](../../README.md)__ ->
__[Blue Prints Overview](../README.md)__ ->
Screens Overview

### Available Screen Hash Keys:
__Hooks__:
*    [live?](#live)
*    [before_load](#before_load)
*    [accept](#accept)
*    [dismiss](#dismiss)

__Definitions__:

*    [modals](#modals)
*    [included_views](#included_views)
*    [automation_screen_changes](#automation_screen_changes)
*    [elements](#elements)

---

#### [modals](modals.md):

__Class__: Hash

__Description__:

Used for storing modals that can show while interacting in a screen.
Link [modals](modals.md) contains more information on modals.

__Important__:

Will add Modal Objects to a Screen Object.  Will need a hook showing the modal to occur before being used.

__Example__:
```
default_screen: 'home_screen'
screens:
  example_screen:
    modals:
      example_modal:
        elements:
          modal_element:
            xpath: '//xpath'
    elements:
      example_button:
        xpath: '//xpath'
        click:
          after:
            show_modal: 'example_modal'
```

---

#### included_views:

__Class__: Array

__Description__:

Expects an Array of [views](../views.md) that are included in the given screen.
[Views Overview](../views.md) gives a more detailed description of implementation.
Using views are an efficient way to include similarities in screens.

__Important__:

Including views will take the Hash definition of that view and merge it with the screen hash

__Example__:
```
default_screen:
views:
  example_view:
    elements:
      example_element:
        xpath: '//xpath'
  second_example_view:
      elements:
        second_example_element:
          xpath: '//xpath'
screens:
  home_screen:
    included_views:
      - 'example_view' #home_screen will now have example_element
  example_screen:
    included_views:
      - 'example_view' #example_screen will now have example_element
      - 'second_example_view' #example_screen will also now have second_example_element
```

---

#### automation_screen_changes:

__Class__: Array

__Description__:

Accepts a list of screens from which the screen can change to.
This key defined in the screen will start a Thread to monitor whether or not the screen has changed or not.
When the screen changes a new current screen will be set.  Useful for possible automatic screen changes and
listening and performing actions on those events.

__Important__:

Any defined screen in this Array should have a live? configuration.

__Example__:
```
default_screen: 'home_screen'
screens:
  home_screen:
    automatic_screen_changes:
      - 'example_screen'
  example_screen:
    live?:
      elements:
        - element_name: 'example_button'
          exists?: true
        - element_name: 'another_button'
          exists?: true
    elements:
      example_button:
        xpath: '//xpath/to/button'
      another_button:
        xpath: '//xpath'
```

---

#### [live?](live.md):

__Class__: Hash

__Description__:

Unique screen hook definition that will validate whether or not a screen is actually live.  Useful for validating screen
changes and for automatic screen changing. [Live? Overview](live.md) document has more detailed information on this screen hook.

__Important__:

Will throw a run time exception if a screen has changed but does not meet the requirements defined.

__Example__:
```
default_screen: 'home_screen'
screens:
  home_screen:
    automatic_screen_changes:
      - 'example_screen'
    live?:
      elements:
        - element_name: 'home_button'
          exists?: true
    elements:
      home_button:
        css: '#css'
  example_screen:
    automatic_screen_changes:
      - 'home_screen'
    live?:
      elements:
        - element_name: 'example_button'
          exists?: true
    elements:
      example_button:
        css: '#css'
```

---

#### [before_load](../hooks/README.md):

__Class__: Hash

__Description__:

Hook definition for when a screen has been set as the current screen.  Link [before_load](../hooks/README.md)
above shows the options for all hooks.

__Example__:
```
default_screen: 'home_screen'
screens:
  home_screen:
    before_load:
      sleep: 1
      wait_for_elements:
        - element_name: 'loading_button'
          exists?: true
          visible?: false
    elements:
      loading_button:
        xpath: '//xpath/to/button'
```

---

#### [elements](elements/README.md):

__Class__: Hash

__Description__:

Contains all of the elements a screen or modal can have.  Keys defined in elements
are defined by the element name you would like to use.

Link above [elements](elements/README.md) describes element definitions in much greater detail.

__Important__:

Use lower case and underscores when defining elements

__Example__:
```
default_screen: 'home_screen'
screens:
  home_screen:
    elements:
      element_example_one:
        xpath: '//xpath/to/element'
      element_example_two:
        css: '#css'
#Representing in Ruby as something like this
#automation_object.home_screen.element_example_one
#automation_object.home_screen.element_example_two
```
---

#### [accept](accept.md):

__Class__: Hash

__Description__:

Hook method that occurs when this screen is a prompt and the accept method has been called.

Link above [accept](accept.md) contains more detail on this hook.

__Important__:

Use only when a screen happens to be a prompt.  Typically describe prompts as screens.

__Example__:
```
default_screen: 'home_screen'
screens:
  home_screen:
    elements:
      example_button:
        xpath: '//xpath'
        click:
          after:
            change_screen: 'example_prompt'
  example_prompt:
    accept:
      after:
        change_screen: 'another_screen'
    dismiss:
      after:
        change_to_previous_screen: true
```
---

#### [dismiss](dismiss.md):

__Class__: Hash

__Description__:

Hook method that occurs when this screen is a prompt and the accept method has been called.

Link above [accept](accept.md) contains more detail on this hook.

__Important__:

Use only when a screen happens to be a prompt.  Typically describe prompts as screens.

__Example__:
```
default_screen: 'home_screen'
screens:
  home_screen:
    elements:
      example_button:
        xpath: '//xpath'
        click:
          after:
            change_screen: 'example_prompt'
  example_prompt:
    accept:
      after:
        change_screen: 'another_screen'
    dismiss:
      after:
        change_to_previous_screen: true
```
---