class CreateProcuringEntities < ActiveRecord::Migration[5.2]
  def change
    create_table :procuring_entities do |t|
      t.string :identifier
      t.string :name_en
      t.string :name_fr
      t.string :street_address
      t.string :city
      t.string :province
      t.string :postal_code

      t.timestamps
    end
    add_index :procuring_entities, :identifier, unique: true
  end
end
