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

Notes from an Email
----------

The idea is based on some hacks that we have running for Gazelle to build gems for private code (which happens to be on github) and publish them on a private server for deployment. What we have works (more or less), but I came up with the name in the shower one morning and couldn't resist.

A few thoughts:

 * I was thinking about rewriting the scripts in ruby, both for accessibility to the community of users and to get rid of some code duplication.
 * You need to have a few gems in the local repo to support the commands used to build the gems. It kinda sucks to pollute the gem repo with extra stuff. It's only a few gems right now, but it could get worse as features are added to the tool. We might need to vendor the gems to avoid that.
 * If the user has rvm installed, it might be helpful to leverage that in the tool. I haven't thought it through, but there might be some useful tricks.
 * One of my goals is to keep it as isolated as possible, so that you can build gems and run the gem server from a single directory, without needing sudo or any special permissions.
 * It assumes that you're using some other web server to serve the gem index files. (We use Apache). But, any simple file server would do. Setting up a simple Rack or Sinatra app to serve the files would be nice, so folks could use their favorite rack-based web server.
 * I'd like to also have a management interface to kick off builds of gems or to rebuild the index on demand. The data model is pretty simple, so I was thinking of starting with just a yaml file to store the list of gems and gem repos. sqlite or something like that is an option if things get complex, but again, the goal is to minimize dependencies as much as possible.
