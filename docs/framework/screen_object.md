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
*    [scroll_down](#scroll_down)
*    [scroll_left](#scroll_left)
*    [scroll_right](#scroll_right)
*    [scroll_up](#scroll_up)
*    [set_window_location](#set_window_location)
*    [set_window_size](#set_window_size)

### accept:

__Description__: Use this method when a screen is also a prompt.  Will accept the prompt when calling this method

__Parameters__: None

__Returns__: Nil

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
automation_object.terms_prompt.accept
```
---

### close_window:

__Description__: Browser only, use this to close the window

__Parameters__: None

__Returns__: Nil

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
automation_object.new_window_screen.close_window
#If there is any other screens that are live they will still be accessible
puts automation_object.home_screen.title_text.text
```
---

### current_url:

__Description__: Browser only, use this to get the url of the screen

__Parameters__: None

__Returns__: String, url that the screen is on

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
puts automation_object.home_screen.current_url
```
---

### dismiss:

__Description__: Use this method when a screen is also a prompt.  Will dismiss the prompt when calling this method

__Parameters__: None

__Returns__: Nil

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
automation_object.additional_info_prompt.dismiss
```
---

### get_window_size:

__Description__: Use this method to get the window size of the browser or app

__Parameters__: None

__Returns__: Hash [:x => Numeric, :y => Numeric]

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
```
---

### hide_keyboard:

__Description__: Mobile Only, use this to hide the keyboard that will appear when typing in an input.

__Parameters__: close_key (String) (default = nil)

__Returns__: Nil

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
automation_object.home_screen.hide_keyboard

#Have a different default hide keyboard text
automation_object.home_screen.hide_keyboard('Done')
```
---

### maximize_window:

__Description__: Use this method to maximize the browser window

__Parameters__: None

__Returns__: Nil

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
automation_object.home_screen.maximize_window
```
---

### navigate_back:

__Description__: Browser only, use this to navigate back. There must be a previous screen to navigate back to.

__Parameters__: None

__Returns__: Nil

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
automation_object.home_screen.second_screen_button.click
automation_object.second_screen.navigate_back
#Now on the home screen
```
---

### screenshot:

__Description__: Take a screenshot of the screen via this method

__Parameters__: path (String), Full file path where you want the image to be stored

__Returns__: Nil

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
automation_object.home_screen.screenshot('//path/to/png/file.png')
```
---

### scroll_down:

__Description__: Action method to scroll down on a screen

__Parameters__: None

__Returns__: Nil

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
automation_object.home_screen.scroll_down
```
---

### scroll_left:

__Description__: Same as above just scrolling left

---

### scroll_right:

__Description__: Same as above just scrolling right

---

### scroll_up:

__Description__: Same as above just scrolling up

---

### set_window_location:

__Description__: Set the browser top left window location via this method

__Parameters__: x (Numeric), y (Numeric)

__Returns__: Nil

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
automation_object.home_screen.set_window_location(100, 200)
```
---

### set_window_size:

__Description__: Set the browser window size via this method

__Parameters__: x (Numeric), y (Numeric)

__Returns__: Nil

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
automation_object.home_screen.set_window_size(1200, 800)
```
---