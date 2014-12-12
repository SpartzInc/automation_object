Possible YAML Blueprint Files Layout
----

It is possible to arrange your blue prints in any directory/file structure as you so choose.  I would recommend splitting
up your YAML files by screens and views.  Here is an example of a directory/file structure we typically use.

Remember all of these hashes are merged into the same hash.  As long as you keep the levels correct you should be fine.

/top_blue_print_directory
  /views #We try to group views together in one folder to keep the above directory for base and screen yaml files
    header_view.yaml
    footer_view.yaml
  base.yaml #Usually use this to define base_url, throttling (if needed), other base level key/values
  home_screen.yaml
  list_screen.yaml
  about_screen.yaml
  help_screen.yaml
  menu_screen.yaml