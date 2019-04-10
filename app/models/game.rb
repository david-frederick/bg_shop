class Game < ApplicationRecord
  validates :name,   presence: true
  validates :bgg_id, presence: true

  def self.generate_all
    rankings_page = BggScraper.new.scrape_rankings
    game_data = BggParser.new.parse(rankings_page)
    create!(game_data)

    Game.all.each do |game|
      BggApi.new.retrieve_game_metadata(game)
    end
  end
end
