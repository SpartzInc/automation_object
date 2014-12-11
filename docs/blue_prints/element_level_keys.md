Element Level Configurations
----

This document will cover the available keys and values that may be used at the base level.

### Table of Contents:

*    [css](#css)
*    [custom_methods](#custom_methods)
*    [custom_range](#custom_range)
*    [define_elements_by](#define_elements_by)
*    [in_iframe](#in_iframe)
*    [multiple](#multiple)
*    [remove_duplicates](#remove_duplicates)
*    [xpath](#xpath)

***

### css:

__Expecting__: String

__Requirements__: Valid css selector to grab the element(s)

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
screens:
  home_screen:
    elements:
      title:
        css: 'div.header h1#title'
  list_screen:
    elements:
      links:
        multiple: true
        css: 'div.links_container a'
```
---

### custom_methods:

__Expecting__: Hash

__Requirements__:

__Description__:

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
---

### custom_range:

__Expecting__: Hash

__Requirements__:

__Description__:



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

__Requirements__: Value is either a valid element method or defined custom method

__Description__:

Use this configuration to create Element Hashes instead of Element Arrays.

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
```
---

### in_iframe:

__Expecting__: String

__Requirements__: Value must be a defined element in the same screen or modal

__Description__:

Use this to define elements that happen to reside in iframes.  Will automatically switch between iframe and default
content when accessing element in iframe and elements in the default content.

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
---

### multiple:

__Expecting__: TrueClass

__Requirements__: Expects only true otherwise don't define multiple, very unnecessary.

__Description__:

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
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
      another_multiple_links_example:
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

__Expecting__:

__Requirements__:

__Description__:



__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
```
---