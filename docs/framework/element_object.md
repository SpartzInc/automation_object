Element Object Documentation
----

Element objects wrap either Selenium element object or Appium element object.  If the method is missing then those
methods will be relayed to the Selenium or Appium object.

[Selenium Element Documentation](https://selenium.googlecode.com/svn/trunk/docs/api/rb/Selenium/WebDriver/Element.html)

[Appium Documentation](https://github.com/appium/ruby_lib/tree/master/docs)

Also ElementHash, ElementArray, and ElementGroup objects will contain Element objects.

Many of the convenience methods are in place for configuration usage such as waiting hooks.

Example Blueprints using convenience methods:
```
default_screen: 'home_screen'
screens:
  home_screen:
    before_load:
      wait_for_elements:
        - element_name: 'title_text'
          exists?: true
          visible?: true
          x: 100
          y: 0
    elements:
      title_text:
        css: 'h1#title'
```

###Below are additional methods provided by AutomationObject:
*    [content](#content)
*    [collides_with_element?](#collides_with_element)
*    [exists?](#exists)
*    [get_box_coordinates](#get_box_coordinates)
*    [get_element_center](#get_element_center)
*    [height](#height)
*    [hover](#hover)
*    [href](#href)
*    [id](#id)
*    [invisible?](#invisible)
*    [scroll_into_view](#scroll_into_view)
*    [scroll_to_view](#scroll_to_view)
*    [visible?](#visible)
*    [width](#width)
*    [x](#x)
*    [y](#y)

### content:

__Description__:  Convenience method for getting the attribute 'content'. i.e. return element.attribute('content')

__Parameters__: None

__Returns__: String, attribute('content') from element

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
puts automation_object.home_screen.meta_tag_element.content
```
---

### collides_with_element?:

__Description__: Use this method to figure out whether or not an Element collides with another.  Pass another
element object into this method to get a true or false answer.  If you have slight overlap on your elements and you
expect that you can input collision_tolerance as the second parameter in pixels.  That will return false as long
as the collision is within tolerance of the pixels you set it to.

__Parameters__: second_element_object (Element), collision_tolerance (Numeric)

__Returns__: TrueClass or FalseClass.  Returns true when colliding, false when it is not.

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)

first_element = automation_object.home_screen.first_element
second_element = automation_object.home_screen.second_element

puts first_element.collides_with_element?(second_element)
#Same as doing
puts second_element.collides_with_element?(first_element)

#Now check add a tolerance of 5 pixels, so if the elements overlap by 5 pixels will still return false
puts second_element.collides_with_element?(first_element, 5)
```
---

### exists?:

__Description__: Use this method to check whether or not the element exists.

__Parameters__: None

__Returns__: TrueClass or FalseClass

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)

puts automation_object.home_screen.title.exists?
puts automation_object.home_screen.description.exists?
```
---

### get_box_coordinates:

__Description__: Use this method to get the box coordinates of an element

__Parameters__: None

__Returns__: Hash, [:x1 => Numeric, :y1 => Numeric, :x2 => Numeric, :y2 => Numeric]

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)

puts automation_object.home_screen.title.get_box_coordinates
#maybe prints out something like [:x1 => 10.5, :y1 => 100, :x2 => 125, :y2 => 150]
```
---

### get_element_center:

__Description__:  Use this method to get the center of the element.

__Parameters__: None

__Returns__: Hash [:x => Numeric, :y => Numeric]

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)

puts automation_object.home_screen.title.get_element_center
```
---

### height:

__Description__: Convenience method for getting the height, instead of calling element.size.height

__Parameters__: None

__Returns__: Numeric, height of the element

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
puts automation_object.home_screen.title.height
```
---

### hover:

__Description__: Action convenience method for simulating hovering over an element

__Parameters__: None

__Returns__: Nil

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
automation_object.home_screen.title.hover #Hover over the title
```
---

### href:

__Description__:  Convenience method for getting the element attribute href

__Parameters__: None

__Returns__: String, attribute('href')

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
puts automation_object.home_screen.sample_link.href
```
---

### id:

__Description__: Convenience method for getting the element attribute id

__Parameters__: None

__Returns__: String, attribute('id')

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
puts automation_object.home_screen.title_text.id
```
---

### invisible?:

__Description__: Convenience boolean method for checking if the element is invisible?.  Returns true if invisible,
false if visible.

__Parameters__: None

__Returns__: TrueClass or FalseClass

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
puts automation_object.home_screen.title_text.invisible?
```
---

### scroll_into_view:

__Description__: Action convenience method for scrolling an element into view.  I also added some extra code to
scroll the object into the middle of the screen if possible instead of the default functionality
that scrolls it to the top of the screen.

__Parameters__: None

__Returns__: Nil

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
automation_object.home_screen.footer.scroll_into_view
```
---

### scroll_to_view:

__Description__: Same as above, just slightly different name

---

### visible?:

__Description__: Similar to [invisible?](#invisible).  Will return true if the element is visible and false if the
element is invisible.

__Parameters__: None

__Returns__: TrueClass or FalseClass

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
puts automation_object.home_screen.title_text.visible?
```
---

### width:

__Description__: Convenience method for getting the width of the element instead of calling element.size.width

__Parameters__: None

__Returns__: Numeric

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
puts automation_object.home_screen.title_text.width
```
---

### x:

__Description__: Convenience method for getting the x coordinate of the element instead of calling element.location.x

__Parameters__: None

__Returns__: Numeric

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
puts automation_object.home_screen.title_text.x
```
---

### y:

__Description__: Convenience method for getting the y coordinate of the element instead of calling element.location.y

__Parameters__: None

__Returns__: Numeric

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
puts automation_object.home_screen.title_text.y
```
---