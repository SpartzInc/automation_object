## Hooks Example

This example has a bit tougher UI to automatic because there is a loading bar that shows in between the changing of screens.
In the blue prints you will see how I cope with this and use hooks to wait for the loading bar to disappear and the screen
to appear then allow to continue.

Some of the hooks are a little redundant but I wanted to display a couple different ways to deal with hooks.

### Installation and Execution

1. cd into this directory
2. Run command 'bundle install' to install the gems needed
3. Run command 'ruby run.rb' to run the script already made to interact with the UI
4. Press enter to quit

### play.rb usage

This file will allow you to execute commands in the console and test out the framework.  Console will ask which command
you would like to input eg 'automation_object.first_screen.next_button.click'.

When you are done executing commands press control+c to exit the loop then press enter to quit.
