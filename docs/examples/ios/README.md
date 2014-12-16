## iOS Example

This example is to show how you can use AutomationObject framework to automate apps.  I also recommend you use their
GUI application to grab all the xPaths and layout your blueprints from their.

I did not automate the entire app, just wanted to give you an idea on how to automate iOS apps.

__Important__: You will need to start the Appium server on port 4723 which is the default port.  If you are unfamiliar
 with their node setup you can use their GUI application [here](http://appium.io/).

__Built Using__:
*  xCode 6
*  Appium 1.3.3
*  iPhone 6

Some Additional Links:
[Appium iOS Documentation](https://github.com/appium/ruby_lib/blob/master/docs/ios_docs.md)
[Sample iOS App Used](https://github.com/aryaxt/iOS-Slide-Menu)

### Installation and Execution

1. cd into this directory
2. Run command 'bundle install' to install the gems needed
3. Run command 'ruby run.rb' to run the already script to interact with the UI
4. Press enter to quit

### play.rb usage

This file will allow you to execute commands in the console and test out the framework.  Console will ask which command
you would like to input eg 'automation_object.first_screen.next_button.click'.

When you are done executing commands press control+c to exit the loop then press enter to quit.
