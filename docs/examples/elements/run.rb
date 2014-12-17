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

  #Work with Element
  ap automation_object.home_screen.page_title.text
  ap automation_object.home_screen.page_description.text

  #Work with ElementArray
  automation_object.home_screen.links_array_example.each { |element|
    ap element.text
    ap element.href
  }

  #Work with ElementHash
  automation_object.home_screen.links_hash_example.each { |key, element|
    ap element.text
    ap key
  }

  #Work with ElementGroup
  automation_object.home_screen.links_group_example.each { |element_group|
    #Use sub-element link and print href
    ap element_group.link.href
    #Use sub-element link_description and print the text
    ap element_group.link_description.text
  }

ensure
  puts 'Press enter to quit...'
  input = gets
  automation_object.quit
end