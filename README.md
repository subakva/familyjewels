Project To Do List
==========

Next Up
----------

* Add tasks for cleanly re-generating indexes
* Test installation build with real-world configuration
* Refactor Project#build into Builder class
* Ensure the gems are built in the order they are registered

Big List
----------

* Build binary commands (STARTED)
* Improve handling of error cases
* Use whenever to set up cron scheduling
* Helper scripts for setting up apache static index hosting
* Sinatra (or similar) to serve static indexes
* Sep. gem to provide web interface for management (add/remove/edit/schedule project builds)

Done
----------

* Use Bundler to isolate gem sets from the system gems
* Write automated tests to confirm functionality
* Refactor Project#register into Config class
* Fill in gemspec
* Define rubygems dependencies
* Handle missing support gems (bundler, rake, builder)

Probably Not
----------

* Consider whether to use rvm to manage gemsets (too much installation overhead?)
