class CreateProperties < ActiveRecord::Migration[5.0]
  def change
    create_table :properties do |t|
      t.json :raw_hash
      t.string :address
      t.string :city
      t.string :county
      t.string :state
      t.string :zip
      t.string :country
      t.float :latitude
      t.float :longigute

      t.timestamps
    end
  end
end
