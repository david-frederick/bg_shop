class CreateEndpoints < ActiveRecord::Migration[5.2]
  def change
    create_table :endpoints do |t|
      t.string :url
      t.column :status, :integer, default: 0

      t.timestamps
    end
  end
end
