Framework Object Documentation
----

Framework object is the dynamic DSL framework that will allow you to automate your app/website.
The object will contain all the objects you have defined in your blue prints (YAML files) as well as the instance methods
defined below.

###Accessing screen objects:

Accessing screen objects is fairly simple and depends on how you define your YAML configurations.  The two examples below
will show you how to access those objects.  When accessing a screen that is not currently live, the framework will try
to automatically route to that screen.

__Blue Prints Example (YAML)__:
```
default_screen: 'home_screen'
screens:
  home_screen:
    #Any screen configurations here
  list_screen:
    #Add so on
```

__Accessing Screen Objects in the Framework Object (Using Above Blue Prints)__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
automation_object.home_screen #Gives you the screen object

#Since we didn't do anything to change to the list screen
#When I call the next command, the framework will try to automatically route to that screen
automation_object.list_screen
```

###Framework instance methods:
*    [driver_object](#driver_object)
*    [get_current_screen](#get_current_screen)
*    [on](#on)
*    [print_objects](#print_objects)
*    [quit](#quit)
*    [set_current_screen](#set_current_screen)

### driver_object:

__Description__: Use driver_object which is the extended version used in AutomationObject.  Will also contain thread
safe operations if you are threading, so mutexing is automatically taken care of for you.  Will also throttle if
you have any throttling set in your blue prints.

__Parameters__: None

__Returns__: AutomationObject::Driver::Driver

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
automation_object.driver_object.execute_script('return document.readyState;')

```
---

### get_current_screen:

__Description__: Use this method to get the current screen

__Parameters__: None

__Returns__: Symbol

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
puts automation_object.get_current_screen #:home_screen , or whatever screen maybe current

```
---

### on:

__Description__: Event emitter, only has one usage right now, may have more in the future.  If you would like to bind
on the change_screen event you can use this method.  Implements [EventEmitter](http://shokai.github.io/event_emitter/)

__Parameters__: Symbol (event name)

__Returns__: Nil

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
automation_object.on :change_screen do |screen_name|
  puts "Screen has changed to #{screen_name}"
end
```
---

### print_objects:

__Description__: Prints out nicely formatted information of the dynamic objects contained in the framework object,
such as Screen objects, Modal objects, Element Hash objects, Element Array objects, Element objects.

__Parameters__: None

__Returns__: Nil

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
automation_object.print_objects
```
---

### quit:

__Description__: Use this to quit the AutomationObject framework as well as the driver

__Parameters__: None

__Returns__: Nil

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
automation_object.quit #quits driver too
```
---

### set_current_screen:

__Description__:  Mostly for internal use, but if you need to set a screen manually then you can use this method.

__Parameters__: Screen Name (Symbol or String), Window Handle (If new window otherwise default is false)

__Returns__: Nil

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
automation_object.set_current_screen(:home_screen)

#Set new screen thats in a new window
automation_object.set_current_screen(:new_window_screen, 'window-handle-id')
```
---