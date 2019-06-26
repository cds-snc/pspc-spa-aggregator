class CreateProcurementRecurrences < ActiveRecord::Migration[5.2]
  def change
    create_table :procurement_recurrences do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.datetime :max_date
      t.integer :duration_in_days
      t.references :procurement, foreign_key: true

      t.timestamps
    end
  end
end
