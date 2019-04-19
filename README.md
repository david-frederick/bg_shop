# BOARD GAME SHOPPER

John David Frederick - jfrederick8@gatech.edu

This README will help get this application up and running.

## INSTALLING DEPENDANCIES

Since I asked on Piazza what OS the TAs would be using and didn't get an answer, I'm going to assume you have access to MacOS with [Homebrew](https://brew.sh/) installed. If you're actually using a Linux machine, you should be able to substitute any reference to `brew install` below with `apt-get install` or whatever other library your Linux distro uses for dependancy management.

If you have any issues getting everything setup and running (which is pretty normal for a Rails appliaction), I'd be happy to meet and make sure everything gets installed correctly. Text me if you need an immediate response: (678) 693-1925

### Clone the Repo

`git clone git@github.com:david-frederick/bg_shop.git`

### Ruby/Rails

First you'll need Ruby Version Manager (RVM). Detailed installation instructions can be [found here](https://rvm.io/rvm/install). It should only require the following:

Install GPG to verify the RVM installation package:

`gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
`

Install RVM:

`\curl -sSL https://get.rvm.io | bash -s stable --ruby`

Then you'll use RVM to install the correct version of Ruby:

`rvm install 2.6.1`

Then if you navigate into the app directory (wherever you cloned it), you should be able to run `ruby -v` and see that Ruby `2.6.1` is running.

Then install Rails:

`gem install rails --version 5.2.2`

Double check this using: `rails -v`

At this point you should be able to run `bundle install` which will install almost all of the dependancies for the application. Everything not included in that script is listed below.

### PostgreSQL

Install using:

`brew install postgresql`



### GeckoDriver
GeckoDriver is a library used by Selenium. While Selenium is something I could build into the application (and therefore you don't need to install manually), GeckoDriver requires a manual step.

`brew install geckodriver`

## BRAINSTORMING

Things to Cover:

* Migrations

* `bundle install`

*

* Rake task to actually get good data

* Running services

* Visiting Webpage

## Populate Data

* Create Games: `Game.generate_all`

* Create Shops: `RedditScraper.new.scrape`

* Synch Airtable Changes to DB: `AirtableSyncher.new.sync_records`

* Run Selenium Search Queries: `Shop.update_search_urls`

* `ShopGame.generate_all`

## TODO

* Include `reddit.htm` in actual project
