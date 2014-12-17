## Automatic Screen Changes Example

This example will show you how to use automatic screen changes and when it is appropriate.  Screens will need the live?
configuration in order to let the framework know which screens might be changing while on that screen.  Typically this is
used when the app/site is driving the screen changes and not the automation program.

Threading does occur while automatic screen changes are being monitored, lucky enough; there is mutexing on the driver
object which prevents multiple communications to the driver from occurring.

### Installation and Execution

1. cd into this directory
2. Run command 'bundle install' to install the gems needed
3. Run command 'ruby run.rb' to run the script already made to interact with the UI
4. Press enter to quit

### play.rb usage

This file will allow you to execute commands in the console and test out the framework.  Console will ask which command
you would like to input eg 'automation_object.first_screen.next_button.click'.

When you are done executing commands press control+c to exit the loop then press enter to quit.
