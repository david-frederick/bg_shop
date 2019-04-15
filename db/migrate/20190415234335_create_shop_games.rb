class CreateShopGames < ActiveRecord::Migration[5.2]
  def change
    create_table :shop_games do |t|
      t.integer :game_id
      t.integer :shop_id
      t.string  :url
      t.timestamps
    end
  end
end
