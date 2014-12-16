require 'automation_object'
require 'appium_lib'

#Change to true if you want to see the debug output in the console
AutomationObject::debug_mode = true
AutomationObject::BluePrint::base_directory = File.expand_path(File.dirname(__FILE__))

#Start up Appium driver on port 4723
opts = { caps: { platformName: :ios, deviceName: 'iPhone 6',
                 app: File.join(File.expand_path(File.dirname(__FILE__)), '/SlideMenu.ipa') } }
Appium::Driver.new(opts).start_driver
#Appium sets itself as $driver

begin
  blue_prints = AutomationObject::BluePrint.new('blue_prints')
  automation_object = AutomationObject::Framework.new($driver, blue_prints)

  #Login and go to the home screen
  automation_object.login_screen.username_field.send_keys('blah')
  automation_object.login_screen.password_field.send_keys('blah')
  automation_object.login_screen.login_button.click

  #Go back and forth
  automation_object.home_screen.menu_button.click
  automation_object.menu_screen.menu_button.click

  #Then lets test automatic screen routing
  5.times do
    random_number = rand(0..4)

    case random_number
      when 0
        automation_object.friends_screen
      when 1
        automation_object.home_screen
      when 2
        automation_object.login_screen
      when 3
        automation_object.menu_screen
      when 4
        automation_object.profile_screen
    end
  end








ensure
  puts 'Press enter to quit...'
  input = gets
  driver.quit
end