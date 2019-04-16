class ShopGame < ApplicationRecord
  belongs_to :game
  belongs_to :shop

  def self.generate_all
    shops = Shop.searchable

    # go through the games first so we don't hit any one site too frequently
    Game.all.each do |game|
      shops.each do |shop|
        scraper = ShopScraper.new
        search_text = game.name.downcase.gsub(/\s/, '')
        url = shop.search_string.gsub(/{{ content }}/, search_text)

        if scraper.site_valid?(url)
          create!(shop: shop, game: game, url: url)
        end
      end
    end
  end
end
