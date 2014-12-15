Screen Object Documentation
----

Screen objects are dynamically created at runtime based on the configurations. For example if you defined in your
blue prints a 'home_screen' and 'list_screen' there will be two Screen objects available underneath the framework object.

When accessing a screen object, the framework will try to automatically route to that screen or do nothing if the screen
is already live.  If there are multiple windows that framework will automatically switch between window handles when accessing
the different live screens.

Screens will also contain Modal, Element, ElementHash, ElementArray, ElementGroup objects that you have defined in
your blue prints.

###Screen object instance methods:
*    [accept](#accept)
*    [close_window](#close_window)
*    [current_url](#current_url)
*    [dismiss](#dismiss)
*    [get_window_size](#get_window_size)
*    [hide_keyboard](#hide_keyboard)
*    [maximize_window](#maximize_window)
*    [navigate_back](#navigate_back)
*    [screenshot](#screenshot)
*    [scroll_up](#scroll_up)
*    [scroll_down](#scroll_down)
*    [scroll_right](#scroll_right)
*    [scroll_left](#scroll_left)
*    [set_window_location](#set_window_location)
*    [set_window_size](#set_window_size)

### accept:

__Description__:

__Parameters__:

__Returns__:

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
```
---

### close_window:

__Description__:

__Parameters__:

__Returns__:

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
```
---

### current_url:

__Description__:

__Parameters__:

__Returns__:

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
```
---

### dismiss:

__Description__:

__Parameters__:

__Returns__:

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
```
---

### get_window_size:

__Description__:

__Parameters__:

__Returns__:

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
```
---

### hide_keyboard:

__Description__:

__Parameters__:

__Returns__:

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
```
---

### maximize_window:

__Description__:

__Parameters__:

__Returns__:

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
```
---

### navigate_back:

__Description__:

__Parameters__:

__Returns__:

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
```
---

### screenshot:

__Description__:

__Parameters__:

__Returns__:

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
```
---

### scroll_up:

__Description__:

__Parameters__:

__Returns__:

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
```
---

### scroll_down:

__Description__:

__Parameters__:

__Returns__:

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
```
---

### scroll_right:

__Description__:

__Parameters__:

__Returns__:

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
```
---

### scroll_left:

__Description__:

__Parameters__:

__Returns__:

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
```
---

### set_window_location:

__Description__:

__Parameters__:

__Returns__:

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
```
---

### set_window_size:

__Description__:

__Parameters__:

__Returns__:

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
```
---