class CreateProperties < ActiveRecord::Migration[5.0]
  def change
    create_table :properties do |t|
      t.string :name
      t.text   :description
      t.string :formatted_address
      t.string :address
      t.string :city
      t.string :county
      t.string :state
      t.string :state_code
      t.string :zip
      t.string :country
      t.float  :latitude
      t.float  :longitude
      t.json   :amenities
      t.json   :pet
      t.integer :rent_min
      t.integer :rent_max

      t.references :management, foreign_key: true

      t.timestamps
    end
  end
end
