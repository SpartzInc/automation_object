require 'automation_object'
require 'selenium-webdriver'

#Change to true if you want to see the debug output in the console
AutomationObject::debug_mode = false
AutomationObject::BluePrint::base_directory = File.expand_path(File.dirname(__FILE__))

#begin
driver = Selenium::WebDriver.for :chrome
blue_prints = AutomationObject::BluePrint.new('blue_prints')
#Hack for local html file, which can change depending on your computer file structure
blue_prints['base_url'] = 'file:///' + File.join(File.expand_path(File.dirname(__FILE__)), '/html/site.html').to_s

automation_object = AutomationObject::Framework.new(driver, blue_prints)

#first_screen is the default start screen
#but lets try to get to some screens that are not live by just calling the screen

#Should automatically route to the third screen and print out the title
puts automation_object.third_screen.title_text.text

#Should automatically route to the first screen and click the next button
#Which will take us then to the second screen
automation_object.first_screen.next_button.click

#ensure
puts 'Press enter to quit...'
input = gets
driver.quit
#end