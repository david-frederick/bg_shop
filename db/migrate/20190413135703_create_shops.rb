class CreateShops < ActiveRecord::Migration[5.2]
  def change
    create_table :shops do |t|
      t.string  :name
      t.string  :url
      t.string  :phone
      t.string  :country
      t.string  :region
      t.string  :city
      t.text    :raw_data
      t.text    :raw_followup
      t.boolean :has_cart
      t.boolean :has_site
      t.boolean :url_valid

      t.timestamps
    end
  end
end
