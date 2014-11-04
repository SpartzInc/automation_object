require 'automation_object'
require 'selenium-webdriver'

AutomationObject::debug_mode = true
AutomationObject::BluePrint::base_directory = File.expand_path(File.dirname(__FILE__))

driver = Selenium::WebDriver.for :chrome
blue_prints = AutomationObject::BluePrint.new('blue_prints')
automation_object = AutomationObject::Framework.new(driver, blue_prints)

#Need to set manually because YAML configuration base_url is not dynamic
site_html_path = 'file:///' + File.join(File.expand_path(File.dirname(__FILE__)), 'site.html').to_s
driver.navigate.to(site_html_path)

puts 'Press enter to quit'
input = gets
automation_object.quit
