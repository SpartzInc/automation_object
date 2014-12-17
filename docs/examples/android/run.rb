require 'automation_object'
require 'appium_lib'

#Change to true if you want to see the debug output in the console
AutomationObject::debug_mode = true
AutomationObject::BluePrint::base_directory = File.expand_path(File.dirname(__FILE__))

#Start up Appium driver on port 4723
opts = {caps: {platformName: :android, deviceName: :android,
               app: File.join(File.expand_path(File.dirname(__FILE__)), '/robodemo-sample-1.0.1.apk')}}
Appium::Driver.new(opts).start_driver
#Appium sets itself as $driver

begin
  blue_prints = AutomationObject::BluePrint.new('blue_prints')
  automation_object = AutomationObject::Framework.new($driver, blue_prints)

  #Let's mess around with the help screen
  automation_object.help_screen.never_show_again_checkbox.click
  automation_object.help_screen.ok_button.click #Now on the home_screen

  #Print the list items
  automation_object.home_screen.list_items.each { |list_item|
    puts list_item.text
  }

  #Now lets clear the list and get the list items length, should be 0
  automation_object.home_screen.clear_button.click
  puts automation_object.home_screen.list_items.length

  #Now lets refresh the list and print out the length
  automation_object.home_screen.refresh_button.click
  puts automation_object.home_screen.list_items.length

  #Now open the menu modal and show the help screen again
  automation_object.home_screen.menu_button.click
  automation_object.home_screen.menu_modal.show_again_button.click

  #Puts the current screen, should be the help screen
  puts automation_object.get_current_screen

  #Going to show off automatic routing now, by calling help_screen and home_screen in a loop a few times
  5.times do
    automation_object.home_screen
    automation_object.help_screen
  end
ensure
  puts 'Press enter to quit...'
  input = gets
  automation_object.quit
end