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

__Description__:  Hook configuration to be run when using the accept method on the screen object.  When accepting the prompt
the accept hook will be run before and after the method is run.

__App Blueprint Example__:
```
default_screen: 'home_screen'
screens:
  home_screen:
    elements:
      login_button:
        xpath: '//path/to/button'
        click:
          after:
            change_screen: 'login_prompt'
  login_prompt:
    accept:
      before:
        sleep: 1
      after:
        change_screen: 'home_screen'
    elements:
      username_field:
        xpath: '//path/to/field'
      password_field:
        xpath: '//path/to/field'
```
__Ruby Example with Above Blueprints__:
```
automation_object = AutomationObject::Framework.new(driver, blue_prints)
automation_object.home_screen.login_button.click
automation_object.login_prompt.username_field.send_keys('test@email.com')
automation_object.login_prompt.password_field.send_keys('password')
automation_object.login_prompt.accept
#Now on the home_screen
```
---

### automatic_screen_changes:

__Expecting__: Array

__Requirements__: Requires an Array of defined screens that also have live? configurations.  Only use when the screen
can automatically change without any UI interactions.

__Description__:  Typically this is used for Apps when the app might change screens automatically like a game.  This way
you can wait for screens to change, then test or interact with the UI.

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

automation_object.on :change_screen do |screen_name|
  case screen_name
    when :your_turn_screen
      #Click on the card
      automation_object.your_turn_screen.card_to_play.click
    when :game_results_screen
      #Do something on the results screen
  end
end
```
---

### before_load:

__Expecting__: Hash

__Requirements__:  Hook that runs once a screen before a screen has loaded.  Works slightly differently then other hooks,
there is no before or after sub-keys.

__Description__:  Use to wait for screen to be ready before you interact with it or run the live? configuration.

__Important__: There is no __before__ or __after__ sub-keys on this hook.

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

__Expecting__: String

__Requirements__:

__Description__:

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
```
---

### elements:

__Expecting__: String

__Requirements__:

__Description__:

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
```
---

### included_views:

__Expecting__: String

__Requirements__:

__Description__:

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
```
---

### modals:

__Expecting__: String

__Requirements__:

__Description__:

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
```
---

### live?:

__Expecting__: String

__Requirements__:

__Description__:

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
```
---

### scroll_up:

__Expecting__: Hash

__Requirements__:

__Description__:

__Example__:
```
base_url: 'http://www.google.com'
default_screen: 'home_screen'
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