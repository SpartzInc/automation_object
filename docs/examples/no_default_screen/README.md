## Simple Example

This example will demonstrate how to set up blue prints when there is no initial default screen.
The framework then will rely on live? configurations of screens to figure out which screen is the initial screen
and will set it accordingly.  Since the is automatic screen routing, it is still safe to ask for the first screen
even if you are on the fourth screen as long as there is a way to get there in the blue prints.

### Installation and Execution

1. cd into this directory
2. Run command 'bundle install' to install the gems needed
3. Run command 'ruby run.rb' to run the script already made to interact with the UI
4. Press enter to quit

### play.rb usage

This file will allow you to execute commands in the console and test out the framework.  Console will ask which command
you would like to input eg 'automation_object.first_screen.next_button.click'.

When you are done executing commands press control+c to exit the loop then press enter to quit.
