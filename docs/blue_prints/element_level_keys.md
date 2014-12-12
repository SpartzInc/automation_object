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

__Description__:  Use this or xpath to define where you element is going to be on the page so that the framework
can work with and supply you with the element.

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

__Requirements__: Defining element_method and evaluate properly.  element_method needs to be a valid available element
method to run ruby code against.  evaluate needs to be valid ruby code.

__Description__: Below ruby code is run when



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
Code run when requesting the custom method:
```
return element_object.href.evaluate('match(/^.+\/lists\/(\d+).+$/)[1].to_i')
```

---

### custom_range:

__Expecting__: Hash

__Requirements__: Element is multiple, start and stop are defined as integers.  1 is the beginning.

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

__Requirements__: Value is either a valid element method or defined custom method

__Description__:

Use this configuration to create Element Hashes instead of Element Arrays.  When the elements are loaded, the framework
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

__Description__: Use this when you need to define sets of elements.  Elements can be Element Hashes or Element Arrays.
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