## Views Example

Views example will give you an idea on how to use views.  Views will basically allow you not to repeat yourself
screen to screen by grouping commonalities into views and including those views in screens.

I created to views: page_header_view.yaml and screen_before_load.yaml which contains the page header text which never
changes and before load hooks that are common to each of those screens.

### Installation and Execution

1. cd into this directory
2. Run command 'bundle install' to install the gems needed
3. Run command 'ruby run.rb' to run the already script to interact with the UI
4. Press enter to quit

### play.rb usage

This file will allow you to execute commands in the console and test out the framework.  Console will ask which command
you would like to input eg 'automation_object.first_screen.next_button.click'.

When you are done executing commands press control+c to exit the loop then press enter to quit.
