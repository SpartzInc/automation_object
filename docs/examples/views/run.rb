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

  #Start on first screen and print our page header view elements then repeat on each screen
  ap automation_object.first_screen.page_title.text
  ap automation_object.first_screen.page_description.text

  ap automation_object.second_screen.page_title.text
  ap automation_object.second_screen.page_description.text

  ap automation_object.third_screen.page_title.text
  ap automation_object.third_screen.page_description.text

  ap automation_object.fourth_screen.page_title.text
  ap automation_object.fourth_screen.page_description.text

  ap automation_object.fifth_screen.page_title.text
  ap automation_object.fifth_screen.page_description.text
ensure
  puts 'Press enter to quit...'
  input = gets
  driver.quit
end