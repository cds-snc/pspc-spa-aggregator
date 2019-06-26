class CreateContactLanguages < ActiveRecord::Migration[5.2]
  def change
    create_table :contact_languages do |t|
      t.references :contact, foreign_key: true
      t.string :code

      t.timestamps
    end
  end
end
