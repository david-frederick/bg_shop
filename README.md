# BOARD GAME SHOPPER

David Frederick - j.david.frederick.57@gmail.com

This is a class project I built for my Enterprise Computing class. The main goal was to explore various software architechture concepts with some source of Big Data. For more information on the objectives and architecture of this project, [please see the resulting paper](https://docs.google.com/document/d/1ZtHeZLwRb5XCrAHiVPZwqIOw09eOeeYW9gC66xOdFGc/edit?usp=sharing).

This README will help get this application up and running.

## -- INSTALLING DEPENDANCIES --
Since I asked on Piazza what OS the TAs would be using and didn't get an answer, I'm going to assume you have access to MacOS with [Homebrew](https://brew.sh/) installed. If you're actually using a Linux machine, you should be able to substitute any reference to `brew install` below with `apt-get install` or whatever other library your Linux distro uses for dependancy management.

If you have any issues getting everything setup and running (which is pretty normal for a Rails appliaction), feel free to email me.

### Clone the Repo

* `git clone git@github.com:david-frederick/bg_shop.git`

### Setup Ruby and Rails
First you'll need Ruby Version Manager (RVM). Detailed installation instructions can be [found here](https://rvm.io/rvm/install). It should only require the following:

Install GPG to verify the RVM installation package:

 * `gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB`

Install RVM:

 * `\curl -sSL https://get.rvm.io | bash -s stable --ruby`

Then you'll use RVM to install the correct version of Ruby:

 * `rvm install 2.6.1`

Then if you navigate into the app directory (wherever you cloned it), you should be able to run `ruby -v` and see that Ruby `2.6.1` is running. If that doesn't work, you may need to run `rvm use ruby-2.6.1`.

Next install Rails

 * `gem install rails --version 5.2.2`

Double check this using: `rails -v`

At this point you should be able to run `bundle install` which will install almost all of the dependancies for the application. Everything not included in that script is listed below.

### PostgreSQL

 * `brew install postgresql`

After that, follow any instructions given by the console. I believe you'll have to setup a system-level login.

### GeckoDriver
GeckoDriver is a library used by Selenium. While Selenium is something I could build into the application (and therefore you don't need to install manually), GeckoDriver requires a manual step.

 * `brew install geckodriver`

## -- DATABASE SETUP --

Lets start up a postgres console:

 * `psql -h localhost -U <your_username> postgres`

**Note:** `\q` gets you out of a psql console. Figuring that out is annoying.

### Create Database

* `CREATE DATABASE bg_shop_development;`

### Create User

Now we need to create a postgres user for the application to use. The username/password need to match whatever is in `config/database.yml`. So if you want to use a different password than I did, be sure to update that file.

* `CREATE ROLE bg_shop WITH PASSWORD 'CS-6365-A';`
* `ALTER ROLE bg_shop WITH LOGIN SUPERUSER;`
* `GRANT ALL ON DATABASE bg_shop_development TO bg_shop;`

You can use `\du` to list the users. You should see the bg_shop user with superuser permissions.

### Update Database Schema

Leave the psql console (`\q`) and make sure you're in the project directory.

The following will create all of the necessary tables for this project. (But won't generate any actual data.)

* `bundle exec rake db:migrate`

## -- SCRAPE DATA --

At this point you should have the app working. But your database won't have any data yet, so looking through the app wouldn't be interesting. So instead we'll start with running some scripts.

Running the following in the app directory will start up a Rails console. From here you can run whichever pieces of my code you want.

 * `bundle exec rails c`

You can run `exit` to leave this console.

At this point I'll go through the scripts that you need to run in order to see my project do it's thing.

### Scrape Games Data

First we want to populate the games table. To do this, we'll run:

 * `Game.generate_all`

You can see this code in `models/game.rb`. This method coordinates all of the stateless services needed to scrape, parse, and create Game objects. (These services can be found in the `services` folder.) In particular, this method triggers the following:
 * `BggScraper` retrieves the HTML of the [BGG rankings page](https://boardgamegeek.com/browse/boardgame) using an HTTP request. It then passes the response into the Nokogiri library which provides a searchable HTML document object.
 * The `BggParser` service then identifies the name and BGG ID of each game on the page.
 * `BggApi` then retrieves each game’s metadata using the XML API provided by BGG.
 * The `Game` model then saves this data to the PostgreSQL DB.

Once that script is done running you should be able to look at some Game objects in the console.

 * `ap Game.first`

### Scrape Shop Data

What I would do next is scrape the [Reddit FLGS Wiki Page](https://www.reddit.com/r/boardgames/wiki/flgs) by running `RedditScraper.new.scrape`. (See `services/reddit_scraper.rb`). However, this takes a long time to run and isn't strictly necessary. Still, I want to point out what it does:

Since Reddit’s API is so strict I chose to download a copy of the page’s HTML manually into a local file (the `reddit_fls.htm` file in the project root directory). Then...

 * The `RedditParser` service takes the HTML file and parses out, as accurately as possible, each shop organized into country, region, and city. It attempts to identify the shop’s website, phone number, and name.
 * `RedditScraper` then takes that data and creates a `Shop` object for each one. This triggers a few important things:
   * It creates a local Postgres object, giving me an ID needed to later synch the data between Postgres and Airtable.
   * It triggers validations on the `Shop`’s URL (see `models/shop.rb` and look at the `verify` method. This will also use some methods from `services/shop_scraper.rb`). These check to see if the URL is formatted correctly, whether the site is running (returns a valid HTTP status code), and whether the site seems to have a shopping cart.
 * All of this information is then passed into the `AirtableSyncher` which writes all of the data to Airtable through their API.

You can see the resulting data [in airtable](https://airtable.com/invite/l?inviteId=invKdywP4Nt17RMvI&inviteToken=ca4e9e34be9ff15a3c31e661f632330481fcc8bf68e5a7f1afe1d70d6baf5097).

### Synch Postgres with Airtable

At this point I would run `AirtableSyncher.new.sync_records` to update my postgres database to reflect the contents of Airtable.

This, however, takes a long time to run and also wouldn't work on your system because I'm having you skip that last script. So instead you'll run the following simplified version which will create some some good data for you without taking forever.

 * `AirtableSyncher.new.ta_records`

### Query Shop Pages for Search Strings

This job scrapes each individual shop site and issues a search query into the page’s search form. This can’t be done by simply retrieving and parsing the shop’s HTML. Instead the app uses Selenium WebDriver to programmatically interact with each shop as if we were a web browser and enters a sample search string into the form. It then checks the URL the browser is directed to and uses that to reverse engineer the site’s search URL. This is best explained with an example:

If we issue the “burdell” search query into the search bar on GameZilla.com, we are redirected to:

        `http://www.gamezilla.ca/products/search?q=burdell`
We can then infer that

        `http://www.gamezilla.ca/products/search?q=<search_content>`
Will direct us to the site’s search results for `<search_content>`.
We save these template search strings on the `Shop` object such that we can inject the game’s name when it is time to build each game’s individual link.

**NOTE:** This will open Mozilla firefox on your machine and start interacting with the shop's webpage automatically. This is by design. I don't expect this to take too long, but I recommend not try to use your computer during this process.

To run this use:

 * `Shop.update_search_urls`

Now if you look at any of the `Shop` objects (`ap Shop.first`), you'll see that `search_string` field has been populated with a `{{ content }}` placeholder. This string will be used to generate links for each game.

### Generate Game Search URLs

Lastly, we'll run: (This should run for about 5 minutes)

 * `ShopGame.generate_all`

Now that search strings for each individual shop have been reverse engineered, we can generate the specific search link for each game. This job iterates through each `Game` and generates the search string for any searchable `Shop`. It then validates whether the URL returns a valid HTTP status code and saves this as a `ShopGame`.

You can now look at the `ShopGame` objects in the database:

 * `ap ShopGame.first`

## -- RUNNING THE APP --

Finally we have some interesting data. Now we will run the app server in order to play with the actual webpage.

 * `bundle exec rails s`

Now, in your web browser, navigate to `http://localhost:3000/`

You're now looking at my app. You should see a list of 100 games. If you click into one of those games, you'll see a list of 10 links to the search results for the various shops we scraped.

## THANKS!
