Possible YAML Blueprint Files Layout
----

It is possible to arrange your blue prints in any directory/file structure as you so choose.  I would recommend splitting
up your YAML files by screens and views.  Here is an example of a directory/file structure we typically use.

Remember all of these hashes are merged into the same hash.  As long as you keep the levels correct you should be fine.

You will also notice in this example that all of the screens are connected to each other via change_screen

File Structure:
```
/top_blue_print_directory
  /views #We usually try to group views together in one folder
    header_view.yaml
    footer_view.yaml
  base.yaml #Usually use this to define base_url, throttling, other base level key/values
  home_screen.yaml
  list_screen.yaml
  about_screen.yaml
  help_screen.yaml
```
Files Contents:
```
#header_view.yaml
views:
  header_view:
    elements:
      header_logo_button:
        css: 'header div.logo a'
        click:
          after:
            change_screen: 'home_screen'

#footer_view.yaml
views:
  footer_view:
    elements:
      footer_logo_button:
        css: 'footer div.logo a'
        click:
          after:
            change_screen: 'home_screen'
      help_link:
        css: 'footer div.help_link a'
        click:
          after:
            change_screen: 'help_screen'
      about_link:
        css: 'footer div.about_link a'
        click:
          after:
            change_screen: 'about_screen'

#base.yaml
base_url: 'http://www.google.com'
default_screen: 'home_screen'
throttle_driver_methods:
  manage: 2

#home_screen
screens:
  home_screen:
    included_views:
      - 'header_view'
      - 'footer_view'
    elements:
      list_links:
        multiple: true
        css: 'div.list a'
        click:
          after:
            change_screen: 'list_screen'

#list_screen
screens:
  list_screen:
    included_views:
      - 'header_view'
      - 'footer_view'
    elements:
      list_title:
        css: 'h1'
      list_description:
        css: 'div.description p'

#about_screen
screens:
  about_screen:
    included_views:
      - 'header_view'
      - 'footer_view'
    elements:
      title:
        css: 'h1'

#help_screen
screens:
  help_screen:
    included_views:
      - 'header_view'
      - 'footer_view'
    elements:
      title:
        css: 'h1'
```

Some sample ruby code that use this blue prints
```
driver = Selenium::WebDriver.for :chrome
blue_prints = AutomationObject::BluePrint.new('top_blue_print_directory') #Loads all files recursively
automation_object = AutomationObject::Framework.new(driver, blue_prints)

#Go to list screen
automation_object.home_screen.list_links.sample.click #Working with array
#Go to help screen
automation_object.list_screen.help_link.click

#Current screen is help_screen
#Go to a screen automatically
automation_object.about_screen #Will trigger the framework to try to get to that screen

#Print about screen title element text
puts automation_object.about_screen.title.text
```