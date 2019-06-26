class CreateProcurementItems < ActiveRecord::Migration[5.2]
  def change
    create_table :procurement_items do |t|
      t.string :identifier
      t.string :description_en
      t.string :description_fr
      t.integer :quantity
      t.string :units_en
      t.string :units_fr
      t.references :procurement, foreign_key: true

      t.timestamps
    end
  end
end
