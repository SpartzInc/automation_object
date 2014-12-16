require 'automation_object'
require 'selenium-webdriver'

#Change to true if you want to see the debug output in the console
AutomationObject::debug_mode = false
AutomationObject::BluePrint::base_directory = File.expand_path(File.dirname(__FILE__))

puts 'Press control+c to break out of the loop keeping the program alive'

begin
  driver = Selenium::WebDriver.for :chrome
  blue_prints = AutomationObject::BluePrint.new('blue_prints')
  #Hack for local html file, which can change depending on your computer file structure
  blue_prints['base_url'] = 'file:///' + File.join(File.expand_path(File.dirname(__FILE__)), '/html/site.html').to_s

  automation_object = AutomationObject::Framework.new(driver, blue_prints)

  automation_object.on :change_screen do |screen_name|
    case screen_name
      when :first_screen
        puts "Changing to #{automation_object.first_screen.title_text.text}"
      when :second_screen
        puts "Changing to #{automation_object.second_screen.title_text.text}"
      when :third_screen
        puts "Changing to #{automation_object.third_screen.title_text.text}"
      when :fourth_screen
        puts "Changing to #{automation_object.fourth_screen.title_text.text}"
      when :fifth_screen
        puts "Changing to #{automation_object.fifth_screen.title_text.text}"
    end
  end

  loop do
    sleep(1)
  end
ensure
  puts 'Press enter to quit...'
  input = gets
  automation_object.quit
end