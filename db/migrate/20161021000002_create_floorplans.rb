class CreateFloorplans < ActiveRecord::Migration[5.0]
  def change
    create_table :floorplans do |t|
      t.string  :name
      t.text    :description
      t.integer :rent
      t.integer :bathroom_count
      t.integer :bedroom_count

      t.references :property, foreign_key: true

      t.timestamps
    end
  end
end
