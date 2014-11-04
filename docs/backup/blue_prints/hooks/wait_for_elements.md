Wait for Elements Overview
--------
__[Main Overview](../../../README.md)__ ->
__[AutomationObject Overview](../../README.md)__ ->
__[Blue Prints Overview](../README.md)__ ->
__[Hooks Overview](README.md)__ -->
Wait for Elements Overview

Hash that describes what element and what to wait for with that element before completing a hook.

### Important

You will use the available Element methods and describe what those elements should match.

---

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