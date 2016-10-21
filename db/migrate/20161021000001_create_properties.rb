class CreateProperties < ActiveRecord::Migration[5.0]
  def change
    create_table :properties do |t|
      t.string :name
      t.string :address
      t.string :city
      t.string :county
      t.string :state
      t.string :zip
      t.string :country
      t.float :latitude
      t.float :longitude
      t.references :management, foreign_key: true

      t.timestamps
    end
  end
end
