## AutomationObject Overview
__[Main Overview](../README.md)__ -> AutomationObject Overview

AutomationObject documentation includes two main parts, Framework and Blue Prints.
Framework documentation describes the Ruby implementation of AutomationObject.
Blue Prints documentation describes the YAML(Hash) implementation of AutomationObject.
Blue prints are created to map UI which are turn made into various objects available on the Framework object.

###[Blue Prints](blue_prints/README.md) (YAML Configurations)

__Note__: Each blue print document will describe a given level in the hash.

Blue prints are __YAML configuration files__ you can use to map your website or app.
These configuration files can be split up pragmatically and are merged using AutomationObject::BluePrint
which is an extension of Hash.  Sub-folders are also allowed and will recursively merge files.
Typically we split up configuration files by screens (pages).

####Example YAML File
```
base_url: 'https://www.google.com'
default_screen: 'home_screen'
screens:
  home_screen:
    elements:
      search_input:
        xpath: '//xpath/to/element'
      search_button:
        css: '#css_path_to_element'
        click:
            after:
                change_screen: 'search_screen'
```

###[Framework](framework/README.md)

Framework documentation describes the relevant classes/objects/methods that can be used while automating UI.

####Small Ruby Example:
```
require 'selenium-webdriver'
require 'automation_object'

driver = Selenium::WebDriver.for :firefox #Tested on Appium drivers too
blue_prints = AutomationObject::BluePrint.new('/file/path/to/blue/prints/directory') #Directory contains YAML files
automation_object = AutomationObject::Framework.new(driver, blue_prints)

puts blue_prints.class #AutomationObject::BluePrint < Hash
puts automation_object.class #AutomationFramework < Object

automation_object.print_objects #Print out available Screen, Modal, ElementHash, ElementArray, Element object methods

#automation_object.example_screen.example_button.click
#automation_object.example_screen.example_modal.example_text.text
```

### Blue Print to DSL Framework Example

Small Hypothetical Blue Print Example (In YAML):
```
base_url: 'https://www.google.com'
default_screen: 'home_screen'
screens:
  home_screen:
    elements:
      search_input:
        xpath: '//xpath/to/element'
      search_button:
        css: '#css_path_to_element'
        click:
            after:
                change_screen: 'search_screen'
  search_screen:
    elements:
        #And so on
```
Hash < Object Representation:
```
{
  'base_url' => 'https://www.google.com',
  'default_screen' => 'home_screen',
  'screens' => {
    'home_screen' => {
      'elements' => {
        'search_input' => {
          xpath => '//xpath/to/element'
        },
        'search_button' => {
          xpath => '#css_path_to_element'
        },
      }
    }
  }
}
```
DSL Framework Representation:
```
require 'selenium-webdriver'
require 'automation_object'

driver = Selenium::WebDriver.for :firefox #Tested on Appium drivers too
blue_prints = AutomationObject::BluePrint.new('/file/path/to/blue/prints/directory')
automation_object = AutomationObject::Framework.new(driver, blue_prints)

automation_object.home_screen.search_input.send_keys('testing')
automation_object.home_screen.search_button.click
```