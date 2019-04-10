class CreateGames < ActiveRecord::Migration[5.2]
  def change
    create_table :games do |t|
      t.string  :name,   null: false
      t.integer :bgg_id, null: false
      t.text    :description
      t.string  :thumbnail
      t.string  :image
      t.integer :year_published
      t.integer :min_players
      t.integer :max_players
      t.integer :playtime
      t.boolean :bgg_data_collected, default: false
      t.timestamps
    end
  end
end
