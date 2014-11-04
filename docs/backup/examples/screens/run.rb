require 'automation_object'
require 'selenium-webdriver'

AutomationObject::debug_mode = false
AutomationObject::BluePrint::base_directory = File.expand_path(File.dirname(__FILE__))

begin
  driver = Selenium::WebDriver.for :chrome
  blue_prints = AutomationObject::BluePrint.new('blue_prints')

  #Need to set manually because YAML configuration base_url is not dynamic
  blue_prints['base_url'] = 'file:///' + File.join(File.expand_path(File.dirname(__FILE__)), 'site.html').to_s
  automation_object = AutomationObject::Framework.new(driver, blue_prints)

  #Dynamic object that will point to the current screen object
  current_screen = automation_object.current_screen

  #One in the same, if the current screen is the first_screen
  #automation_object.first_screen.next_button.click
  #current_screen.next_button.click

  times_changed_screen = 0

  #Hook to change_screen event emission
  automation_object.on :change_screen do |screen|
    puts 'Changing to screen'
    ap screen

    times_changed_screen = times_changed_screen + 1
    if times_changed_screen < 50
      case screen
        when :first_screen
          current_screen.next_button.click
        when :second_screen
          if rand(0..3) > 0
            current_screen.next_button.click
          else
            current_screen.previous_button.click
          end
        when :third_screen
          if rand(0..3) > 1
            current_screen.next_button.click
          else
            current_screen.previous_button.click
          end
        when :fourth_screen
          if rand(0..3) > 2
            current_screen.next_button.click
          else
            current_screen.previous_button.click
          end
        when :fifth_screen
          automation_object.fifth_screen.previous_button.click
      end
    end
  end

  #Trigger first screen change which will then trigger change_screen events above
  automation_object.first_screen.next_button.click
rescue Exception => e
  puts 'Error Occurred'.colorize(:red)
  ap e
ensure
  puts 'Press enter to quit'
  input = gets

  begin
    automation_object.quit
  rescue
    driver.quit
  end

  raise e if e
end

