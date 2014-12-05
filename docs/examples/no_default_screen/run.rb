require 'automation_object'
require 'selenium-webdriver'

#Change to true if you want to see the debug output in the console
AutomationObject::debug_mode = false
AutomationObject::BluePrint::base_directory = File.expand_path(File.dirname(__FILE__))

begin
  driver = Selenium::WebDriver.for :chrome
  blue_prints = AutomationObject::BluePrint.new('blue_prints')
  #Hack for local html file, which can change depending on your computer file structure
  blue_prints['base_url'] = 'file:///' + File.join(File.expand_path(File.dirname(__FILE__)), '/html/site.html').to_s

  automation_object = AutomationObject::Framework.new(driver, blue_prints)

  #put the initial screen
  ap automation_object.current_screen_class

  #Will route automatically to the first screen if its not on the first screen
  #print out the title text of the first screen

  ap automation_object.first_screen.title_text.text

  #click on the next_button which will change to the next screen automatically
  automation_object.first_screen.next_button.click
  automation_object.second_screen.next_button.click
  automation_object.third_screen.next_button.click
  automation_object.fourth_screen.next_button.click

  #On the last screen now, go backwards and print out the descriptions
  automation_object.fifth_screen.previous_button.click
  automation_object.fourth_screen.previous_button.click
  automation_object.third_screen.previous_button.click
  automation_object.second_screen.previous_button.click
ensure
  puts 'Press enter to quit...'
  input = gets
  driver.quit
end