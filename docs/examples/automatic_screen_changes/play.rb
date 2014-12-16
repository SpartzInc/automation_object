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
  automation_object.quit
end