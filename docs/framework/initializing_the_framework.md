Initializing the framework
----

Initializing the framework requires a few things.  First you will have to load/merge the blue prints from a directory.  Then
you will take the driver object and the blue prints object and create the framework object.

The dynamic DSL framework object will contain all the screens you have created in the blue prints
and will control the changes screens and how you can access those screens.

### Table of Contents:
*    [Simple framework creation](#simple-framework-creation)
*    [Turn on debugging of AutomationObject](#turn-on-debugging-of-automationobject)
*    [Set blue prints base directory](#set-blue-prints-base-directory)
*    [Enable blue print validation](#enable-blue-print-validation)

###Simple framework creation

This is a simple bare-bones example to show you the sets to create a new AutomationObject::Framework object.

```
require 'automation_object'

#Create the driver, could also be Appium
driver = Selenium::WebDriver.for :chrome

#Loads the blue prints (YAML files) from the directory and return the merged Hash object, blue_prints
blue_prints = AutomationObject::BluePrint.new('/full/path/to/blue/prints/directory')

#Initiate the framework object with the driver and blue prints
automation_object = AutomationObject::Framework.new(driver, blue_prints)
```

###Turn on debugging of AutomationObject

This will output messages of actions taken internally as well as driver communications to allow you to debug your
UI automation and help fix any issues you may have.

```
require 'automation_object'

#Create the driver, could also be Appium
driver = Selenium::WebDriver.for :chrome

#Turn on debugging
AutomationObject::debug_mode = true

#Set the base directory and create blue prints
AutomationObject::BluePrint::base_directory = '/base/blue_print/directory'

#Create the blue prints Hash
blue_prints = AutomationObject::BluePrint.new('/relative/path/from/base/directory')

#Initiate the framework object with the driver and blue prints
automation_object = AutomationObject::Framework.new(driver, blue_prints)
```

###Set blue prints base directory

Set the blue prints base directory where you store all your different blue prints so you only have to set
the relative path from there.

```
require 'automation_object'

#Create the driver, could also be Appium
driver = Selenium::WebDriver.for :chrome

#Set the base directory
AutomationObject::BluePrint::base_directory = '/base/blue_print/directory'

#Create the blue prints Hash
blue_prints = AutomationObject::BluePrint.new('/relative/path/from/base/directory')

#Initiate the framework object with the driver and blue prints
automation_object = AutomationObject::Framework.new(driver, blue_prints)
```

###Enable blue print validation

Turning on blue print validation will throw exceptions when your blue prints don't meet the requirements set out for
blue prints.  So if you make mistakes then you can use this to test your blue prints.  I have left this off by default
just in case you have incomplete blue prints and don't want to mess up live tests.

```
require 'automation_object'

#Create the driver, could also be Appium
driver = Selenium::WebDriver.for :chrome

#Set the base directory
AutomationObject::BluePrint::base_directory = '/base/blue_print/directory'

#Turn blue print validation on
AutomationObject::BluePrint::validate_blueprint = true

#Create the blue prints Hash
blue_prints = AutomationObject::BluePrint.new('/relative/path/from/base/directory')

#Initiate the framework object with the driver and blue prints
automation_object = AutomationObject::Framework.new(driver, blue_prints)
```