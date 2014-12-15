Element Object Documentation
----

Element objects wrap either Selenium element object or Appium element object.  If the method is missing then those
methods will be relayed to the Selenium or Appium object.

[Selenium Element Documentation](https://selenium.googlecode.com/svn/trunk/docs/api/rb/Selenium/WebDriver/Element.html)

[Appium Documentation](https://github.com/appium/ruby_lib/tree/master/docs)

Also ElementHash, ElementArray, and ElementGroup objects will contain groups of Element objects.

###Below are additional methods provided by AutomationObject:
*    [content](#content)
*    [collides_with_element?](#collides_with_element?)
*    [exists?](#exists?)
*    [get_box_coordinates](#get_box_coordinates)
*    [get_element_center](#get_element_center)
*    [height](#height)
*    [hover](#hover)
*    [href](#href)
*    [id](#id)
*    [invisible?](#invisible?)
*    [scroll_into_view](#scroll_into_view)
*    [scroll_to_view](#scroll_to_view)
*    [visible?](#visible?)
*    [width](#width)
*    [x](#x)
*    [y](#y)

### content:

__Description__:

__Parameters__:

__Returns__:

__Example__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
```
---