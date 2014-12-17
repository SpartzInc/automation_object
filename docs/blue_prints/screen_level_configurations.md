Screen Level Configurations
----

This document will cover the available keys and values that may be used at the screens level.

### Table of Contents:
*    [accept](#accept)
*    [automatic_screen_changes](#automatic_screen_changes)
*    [before_load](#before_load)
*    [dismiss](#dismiss)
*    [element_groups](#element_groups)
*    [elements](#elements)
*    [included_views](#included_views)
*    [modals](#modals)
*    [live?](#live)
*    [scroll_up](#scroll_up)
*    [scroll_down](#scroll_down)
*    [scroll_left](#scroll_left)
*    [scroll_right](#scroll_right)

***

### accept:

__Expecting__: Hash

__Requirements__: Hook key used when a screen is also a prompt.  This will occur more often then not in App automation.

__Description__:  Hook configuration to be run when using the accept method on the screen object.  When accepting the prompt,
the accept hook will be run before and after the driver method is run.

__Available Before/After Sub-Keys__: [Hook Level Configurations](hook_level_configurations.md)

__App Blueprint Example__:
```
default_screen: 'home_screen'
screens:
  home_screen:
    elements:
      about_us_button:
        xpath: '//path/to/button'
        click:
          after:
            change_screen: 'about_us_prompt'
  about_us_prompt: #Can name screens whatever you want
    accept:
      before:
        sleep: 1
      after:
        change_screen: 'home_screen'
```
__Ruby Example with Above Blueprints__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
automation_object.home_screen.about_us_button.click
#Runs hooks and accepts prompt in UI
#Won't return until hooks are complete
automation_object.about_us_prompt.accept
#Now on the home_screen
```
---

### automatic_screen_changes:

__Expecting__: Array

__Requirements__: Requires an Array of defined screens that also have [live?](#live) configurations.
Only use when the screen can automatically change without any UI interactions.

__Description__:  Typically this is used for apps when the app might change screens automatically like a game.
This way you can wait for screens to change, then test or interact with the UI.  There is also thread protection on
the driver so you can issue commands while a different thread monitors for screen changes.

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'game_lobby_screen'
screens:
  game_lobby_screen:
    automatic_screen_changes:
      - 'your_turn_screen'
  your_turn_screen:
    automatic_screen_changes:
      - 'game_results_screen'
    live?:
      elements:
        - element_name: 'card_to_play'
          exists?: true
    elements:
      card_to_play:
        xpath: '//path/to/card'
  game_results_screen:
    live?:
      elements:
        - element_name: 'results_table'
          exists?: true
    elements:
      results_table:
        xpath: '//path/to/table'

```
__Ruby Example with Above Blueprints__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)

#Use this variable to keep the main thread open via a loop until your finished testing.
break_keep_alive_loop = false
automation_object.on :change_screen do |screen_name|
  case screen_name
    when :your_turn_screen
      #Click on the card
      automation_object.your_turn_screen.card_to_play.click
    when :game_results_screen
      #Do something on the results screen
      break_keep_alive_loop = true
  end
end

#Keep the main thread alive!
until break_keep_alive_loop
  sleep(1)
end
```
---

### before_load:

__Expecting__: Hash

__Requirements__:  Hook that runs before a screen is loaded.  Works slightly differently then other hooks,
there is no before or after sub-keys.

__Description__:  Use to wait for screen to be ready before allowing interactions on that screen.

__Important__: There is no __before__ or __after__ sub-keys on this hook.  Every other hook uses the before and after
sub-keys.

__Available Sub-Keys__: [Hook Level Configurations](hook_level_configurations.md)

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
screens:
  home_screen:
    before_load: #No before or after
      sleep: 1
      wait_for_elements:
        - element_name: 'title_text'
          exists?: true
    elements:
      title_text:
        css: 'h1#title'
      links:
        css: 'a'
        click: #Example of a regular hook with before and after
          before:
            sleep: 1
          after:
            change_screen: 'list_screen'
  list_screen:
#And so on
```
---

### dismiss:

__Expecting__: Hash

__Requirements__: Hook key used when a screen is also a prompt.  This will occur more often then not in App automation.

__Description__:  Hook configuration to be run when using the dismiss method on the screen object.  When dismissing the prompt
the dismiss hook will be run before and after the method is run.

__Available Before/After Sub-Keys__: [Hook Level Configurations](hook_level_configurations.md)

__App Blueprint Example__:
```
default_screen: 'home_screen'
screens:
  home_screen:
    elements:
      about_button:
        xpath: '//path/to/button'
        click:
          after:
            change_screen: 'about_prompt'
  about_prompt:
    dismiss:
      before:
        sleep: 1
      after:
        change_screen: 'home_screen'
```
__Ruby Example with Above Blueprints__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
automation_object.home_screen.about_button.click
automation_object.about_screen.dismiss
#Now on the home_screen
```
---

### element_groups:

__Expecting__: Hash

__Requirements__: xPath's on the elements are required for this.  This is because it's
easier to combine xPaths and indexes to form each group.

__Description__:  Use this when you need to test groups of elements in a pragmatic way.  At our company we use this to
test groups of list links that include an image, link text, as well as the author.

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
screens:
  home_screen:
    element_groups:
      list_links_group: #Only allow use of xPaths because of ease of getting specific indexes
        #xPath below defines the top level element that contains the sub elements.
        xpath: '//div[@id="main_block"]//div[contains(@class, "feed-item")]'
        sub_elements:
          promo_image:
            xpath: '/div[contains(@class, "image")]/a/div/img'
          link_text:
            xpath: '//h4/a'
          author_text:
            xpath: '/div[contains(@class, "details")]/div[contains(@class, "author")]'
```
__Ruby example of above configuration__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
#ElementGroup returns an Array which contains each sub element within it
#This way you can properly test groups of elements without worrying about mixing
#of elements from elsewhere
automation_object.home_screen.list_links_group.each { |link_group|
  puts link_group.promo_image.attribute('src')
  puts link_group.link_text.href
  puts link_group.author_text.text
}
```
---

### elements:

__Expecting__: Hash

__Requirements__: Use this to describe all the elements that a screen contains that you need to work with while
automating.

__Description__: This key can be used to describe single elements, element hashes, and element arrays.

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
screens:
  home_screen:
    elements:
      title_text: #Element, singular
        css: 'h1#title'
      links_array: #ElementArray, multiple
        css: 'a'
        multiple: true
      links_hash: #ElementHash, multiple
        css: 'a'
        multiple: true
        define_elements_by: 'href'
```
__Ruby example of above configuration__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)

#Element
puts automation_object.home_screen.title_text

#ElementArray
automation_object.home_screen.links_array.each { |link_element|
  puts link.text
}

#ElementHash
automation_object.home_screen.links_hash.each { |link_key, link_element|
  puts link_key
  puts link_element.text
}
```
---

### included_views:

__Expecting__: Array

__Requirements__:  Expects an Array of defined views

__Description__: Use this when a view contains configurations relevant to the screen.  Views are used when you have
configurations that can be used for multiple screens.

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
views:
  header_view:
    header_logo_button:
      css: 'header div.logo a'
  footer_view:
    footer_logo_button:
      css: 'footer div.logo a'
screens:
  home_screen:
    included_views:
      - 'header_view'
      - 'footer_view'
  list_screen:
    included_views:
      - 'header_view'
      - 'footer_view'
```
---

### modals:

__Expecting__: Hash

__Requirements__: Use this to define modals that may exist on a screen.

__Description__:  Modals act exactly like screens, but are contained within screens.  Typically used for web,
a good example would be a drop down menu that requires a button to open the modal that contains the menu.

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
screens:
  home_screen:
    modals:
      user_account_menu:
        elements:
          close_menu_button:
            css: '#menu_button'
            close_modal: true
    elements:
      user_menu_button:
        css: '#menu_button'
        click:
          after:
            show_modal: 'user_account_menu'
```
---

### live?:

__Expecting__: String

__Requirements__:  This is used to check that a screen is actually live?, will throw an error when a screen is loaded
and the requirements are not met. Use 'elements' sub-key to define the requirements for that screen to be live.

__Description__: live? configurations can be used when no default screen is present, [automatic_screen_changes](#automation_screen_changes),
and [possible_screen_changes](hook_level_keys.md#possible_screen_changes] hook where the framework has to figure out which screen is live.
Also if you want to throw errors when you not on the screen you expected you would use this.

__Available Before/After Sub-Keys__: [Hook Level Configurations](hook_level_configurations.md)

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
screens:
  home_screen:
    live?:
      before:
        sleep: 1
      elements:
        - element_name: 'title_text'
          exists?: true
          text: 'Home Screen'
      after:
        sleep: 1
    elements:
      title_text:
        css: 'h1#title'
```
---

### scroll_up:

__Expecting__: Hash

__Requirements__:  This hook as well as the ones defined below are called when using the screen object methods:
scroll_up, scroll_down, scroll_left, and scroll_right.  Use before and after hooks to run before and after the method
is called.

__Description__:  This is typically used in Apps where you have scrolling that would reset the elements on the screen or
would change the screen to another.

__Available Before/After Sub-Keys__: [Hook Level Configurations](hook_level_configurations.md)

__Example__:
```
default_screen: 'home_screen'
screens:
  home_screen:
    scroll_up:
      before:
        sleep: 1
      after:
        reset_screen: true
    scroll_right:
      after:
        change_screen: 'list_screen'
    scroll_left:
      after:
        change_screen: 'list_screen'
    scroll_down:
      after:
        reset_screen: true
```
---

### scroll_down:

Same as above just scrolling down

---

### scroll_left:

Same as above just scrolling left

---

### scroll_right:

Same as above just scrolling right