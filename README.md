# BOARD GAME SHOPPER

This README will help get this application up and running.

Things you may want to cover:

* Ruby/Rails Install

* Postgres
  * Migrations


* Sidekiq

* Redis

* `bundle install`

* `brew install geckodriver`

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
