require 'automation_object'
require 'appium_lib'

#Change to true if you want to see the debug output in the console
AutomationObject::debug_mode = true
AutomationObject::BluePrint::base_directory = File.expand_path(File.dirname(__FILE__))

#Start up Appium driver on port 4723
opts = {caps: {platformName: :ios, deviceName: 'iPhone 6', platformVersion: '8.1',
               app: File.join(File.expand_path(File.dirname(__FILE__)), '/SlideMenu.ipa')}}
Appium::Driver.new(opts).start_driver
#Appium sets itself as $driver

begin
  blue_prints = AutomationObject::BluePrint.new('blue_prints')
  automation_object = AutomationObject::Framework.new($driver, blue_prints)

  #Input commands like:
  #automation_object.first_screen.next_button.click
  #automation_object.second_screen.title_text.text

  loop do
    puts 'Input the command you would like to execute'
    input = gets
    input = input.strip

    begin
      ap eval(input)
    rescue Exception => e
      puts 'Error occurred'.colorize(:red)
      ap e
      ap e.class
      ap e.message
      ap e.backtrace
    end
  end
ensure
  puts 'Press enter to quit...'
  input = gets
  driver.quit
end