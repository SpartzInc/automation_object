require 'automation_object'
require 'selenium-webdriver'

#Change to true if you want to see the debug output in the console
AutomationObject::debug_mode = false
AutomationObject::BluePrint::base_directory = File.expand_path(File.dirname(__FILE__))

begin
  #Create Selenium driver
  driver = Selenium::WebDriver.for :chrome

  #Load YAML files and create merged Hash object
  blue_prints = AutomationObject::BluePrint.new('blue_prints')

  #Hack for local html file, which can change depending on your computer file structure
  blue_prints['base_url'] = 'file:///' + File.join(File.expand_path(File.dirname(__FILE__)), '/html/demo/index.html').to_s

  #Create DSL framework
  automation_object = AutomationObject::Framework.new(driver, blue_prints)

  #Open and close FancyBox images on first group
  automation_object.home_screen.group_one_images.each { |image_element|
    #Open FancyBox modal
    image_element.click

    #Close FancyBox modal
    automation_object.home_screen.fancybox_modal.close_button.click
  }

  #Open and close FancyBox images on second group
  automation_object.home_screen.group_two_images.each { |image_element|
    #Open FancyBox modal
    image_element.click

    #Close FancyBox modal
    automation_object.home_screen.fancybox_modal.close_button.click
  }
ensure
  puts 'Press enter to quit...'
  input = gets
  automation_object.quit
end