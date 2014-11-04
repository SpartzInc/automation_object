Views Blue Prints Overview
--------
__[Main Overview](../../README.md)__ ->
__[AutomationObject Overview](../README.md)__ ->
__[Blue Prints Overview](README.md)__ -->
Views Overview

Views are used when Element/ElementHash/ElementArray/Modal/Hooks etc.. can be included in multiple screens.
This can help reduce the overall size of your blue prints by combining commonalities among screens.

### Available View Hash Keys:

See [Screen Documentation](screens/README.md).  All keys defined in a view are the same as a screen hash keys.

### Example:

This example use shows why you would use views in screens

```
default_screen: 'home_screen'
views:
  header_view:
    elements:
      login_button:
        xpath: '//xpath'
      logout_button:
        css: '#css'
      settings_button:
        xpath: '//xpath'
  screens:
    home_screen:
      included_views:
        - 'header_view'
    list_screen:
      included_views:
        - 'header_view'
```

Long hand example of the above configuration blue prints

```
default_screen: 'home_screen'
views:
  screens:
    home_screen:
      elements:
        login_button:
          xpath: '//xpath'
        logout_button:
          css: '#css'
        settings_button:
          xpath: '//xpath'
    list_screen:
      elements:
        login_button:
          xpath: '//xpath'
        logout_button:
          css: '#css'
        settings_button:
          xpath: '//xpath'
```


