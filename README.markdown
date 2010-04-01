Family Jewels
==========

Family Jewels is a private gem builder and server.

Features (Complete)
----------

* None!

Features (TODO)
----------

* web interface to trigger gem index regeneration
* web interface to install a new gem into the index
* password-protection for the web interface
* tool to fetch, build and install gems for a git project
* isolated gem repository (i.e. system gems don't interfere with published gems)

Command Line
----------

To install a gem into the isolated repo, run:

    bin/install_gem [your favorite gem install arguments here]

To regenerate the index for the server:

    bin/update_server

Requirements
----------

* RubyGems must be installed. I'm using 1.3.6, but it may work with other versions.
* The "builder" gem must be installed in the local gem cache in order to generate the index. Run:
    bin/install_gem builder
* The "rake" gem must be installed in the local gem cache in order to install gems. Run:
    bin/install_gem rake
