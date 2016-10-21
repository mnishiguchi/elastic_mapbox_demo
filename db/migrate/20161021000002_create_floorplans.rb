class CreateFloorplans < ActiveRecord::Migration[5.0]
  def change
    create_table :floorplans do |t|
      t.float :rent
      t.text :description
      t.string :name
      t.references :property, foreign_key: true

      t.timestamps
    end
  end
end
