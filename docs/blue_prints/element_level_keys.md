Element Level Configurations
----

This document will cover the available keys and values that may be used at the element level.

### Table of Contents:

*    [Element Level Hooks](#element-level-hooks)
*    [css](#css)
*    [custom_methods](#custom_methods)
*    [custom_range](#custom_range)
*    [define_elements_by](#define_elements_by)
*    [in_iframe](#in_iframe)
*    [multiple](#multiple)
*    [remove_duplicates](#remove_duplicates)
*    [xpath](#xpath)

***

### Element Level Hooks:

__Expecting__: Hash

__Requirements__:  Element methods may be used to define hooks.  The defined method hook in the configuration
will need to be a method available on a Selenium/Appium element object, extension by the Framework
[element object](../framework/element_object.md), or a [custom_method](#custom_methods)

__Description__:  Use hooks on element methods when you expect that those actions will change the state of the automation or
that you need to wait for certain conditions to exist before/after running that method.

__Available Before/After Hook Sub-Keys__: [Hook Level Configurations](hook_level_configurations.md)

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
screens:
  home_screen:
    elements:
      username_field:
        css: '#username'
        send_keys:
          before:
            sleep: 5
          after:
            wait_for_elements:
              - element_name: 'password_field'
                visible?: true #Totally hypothetical, no reason for it to be invisible
        submit:
          after:
            change_screen: 'account_screen'
      password_field:
        css: '#pass'
  account_screen:
  #And so on
```
---

### css:

__Expecting__: String

__Requirements__: Valid css selector to grab the element(s)

__Description__:  Use this or [xpath](#xpath) to define where you element is going to be on the page so that the framework
can work with and supply you with the element.

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
screens:
  home_screen:
    elements:
      title:
        css: 'div.header h1#title' #Element
  list_screen:
    elements:
      links:
        multiple: true
        css: 'div.links_container a' #ElementArray
```
---

### custom_methods:

__Expecting__: Hash

__Requirements__: Defining element_method and evaluate properly are important.
element_method needs to be a valid available [element method](../framework/element_object.md) to run ruby code against.
evaluate needs to be valid ruby code.  The evaluate code is run against the method you supply in element_method.

__Description__: You can use custom methods to create a method on an element object that might not otherwise exist.
By using one of the already available element methods and ruby code under evaluate you can create a dynamic method on that
object.

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
home_screen:
  elements:
    links:
      css: 'a'
      multiple: true
      custom_methods:
        link_id:
          element_method: 'href'
          evaluate: 'match(/^.+\/lists\/(\d+).+$/)[1].to_i'
```
Backend code that runs when requesting the custom method:
```
return element_object.href.evaluate('match(/^.+\/lists\/(\d+).+$/)[1].to_i')
# or return element_object.href.match(/^.+\/lists\/(\d+).+$/)[1].to_i
```

---

### custom_range:

__Expecting__: Hash

__Requirements__: Element is multiple, start and stop are defined as integers.  1 is the beginning, was unsure whether to
start at 0 or 1 because indexes for xPaths/CSS start at 1; so I figured on just starting at 1.

__Description__:  Use this if you need to work with an artificially smaller set of elements.

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
screens:
  elements:
    links:
      css: 'a'
      multiple: true
      custom_range:
        start: 1 #Elements start at one
        stop: 5
```
---

### define_elements_by:

__Expecting__: String

__Requirements__: Value is either a valid [element method](../framework/element_object.md) or defined custom method.

__Description__:

Use this configuration to create an element Hash instead of element Array.  When the elements are loaded, the framework
will run each element method and use the return as the key for that element.

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
screens:
  home_screen:
    elements:
      links_example:
        multiple: true
        css: 'a'
        define_elements_by: 'href'
      links_custom_method_example:
        multiple: true
        css: 'a'
        define_elements_by: 'list_id'
        custom_methods:
          list_id:
            element_method: 'href'
            evaluate: 'match(/^.+\/lists\/(\d+).+$/)[1].to_i'
```
---

### in_iframe:

__Expecting__: String

__Requirements__: Value must be a defined element in the same screen or modal

__Description__:

Use this to define elements that happen to reside in iframes.  Framework will automatically switch between iframe and default
content when accessing element in iframe and other elements in the default content.  So there is no need to script any code
for iframes except in the configurations.

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
home_screen:
  elements:
    iframe_element:
      xpath: '//iframe'
    element_in_iframe:
      xpath: '//path/inside/iframe/to/element'
      in_iframe: 'iframe_element'
```
__Ruby Example with Above Blueprints__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
#No need to access iframe_element, accessing element_in_iframe will automatically switch to the iframe
automation_object.home_screen.element_in_iframe.text
```
---

### multiple:

__Expecting__: TrueClass

__Requirements__: Expects only true otherwise don't define multiple, unnecessary to do so.

__Description__: Use this when you need to define an Array of elements.  Elements can be Element Hashes or Element Arrays.
Use [define_elements_by](#define_elements_by) when you want to have element hashes instead of arrays.

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
screens:
  home_screen:
    elements:
      element_array_example:
        multiple: true
        css: 'a'
      element_hash_example:
        multiple: true
        css: 'a'
        define_elements_by: 'text'
```
---

### remove_duplicates:

__Expecting__: String

__Requirements__: Valid element method or custom method defined in element

__Description__:

Use this to remove duplicates that may exist by eliminating elements by a specific method.

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
screens:
  home_screen:
    elements:
      multiple_links:
        multiple: true
        css: 'a'
        remove_duplicates: 'href'
      another_multiple_links_example: #Use custom method instead
        multiple: true
        xpath: '//a'
        remove_duplicates: 'list_id'
        custom_method:
          list_id:
            element_method: 'href'
            evaluate: 'match(/^.+\/lists\/(\d+).+$/)[1].to_i'
```
---

### xpath:

__Expecting__: String

__Requirements__: Valid xpath selector to grab the element(s)

__Description__:  Use this or css to define where you element is going to be on the page so that the framework
can work with and supply you with the element.

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
screens:
  home_screen:
    elements:
      title:
        xpath: '//path/to/title/element'
```
---