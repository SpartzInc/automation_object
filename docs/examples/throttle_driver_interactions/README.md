## Throttle Driver Interactions Example

This is example is copied over from the Simple example, with the debugging turned on and some of the driver and element
methods throttled.

Take a look at the blue_prints/base.yaml to see how you would throttle methods on the driver or element.

Also debugging is turned on so you can see the output on how long it takes to complete those methods.  The amount of time
at a minimum should be what is set in the blue prints.

### Installation and Execution

1. cd into this directory
2. Run command 'bundle install' to install the gems needed
3. Run command 'ruby run.rb' to run the script already made to interact with the UI
4. Press enter to quit

### play.rb usage

This file will allow you to execute commands in the console and test out the framework.  Console will ask which command
you would like to input eg 'automation_object.first_screen.next_button.click'.

When you are done executing commands press control+c to exit the loop then press enter to quit.
