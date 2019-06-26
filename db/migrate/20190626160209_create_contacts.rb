class CreateContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :contacts do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :fax
      t.string :url
      t.references :procuring_entity, foreign_key: true

      t.timestamps
    end
  end
end
