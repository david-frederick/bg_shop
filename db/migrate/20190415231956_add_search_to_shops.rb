class AddSearchToShops < ActiveRecord::Migration[5.2]
  def change
    add_column :shops, :search_string, :string
  end
end
