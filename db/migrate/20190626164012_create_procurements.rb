class CreateProcurements < ActiveRecord::Migration[5.2]
  def change
    create_table :procurements do |t|
      t.string :ocid
      t.string :tender_id
      t.string :title_en
      t.string :title_fr
      t.string :description_en
      t.string :description_fr
      t.string :recurrence_description_en
      t.string :recurrence_description_fr
      t.string :options_en
      t.string :options_fr
      t.datetime :contract_start_date
      t.datetime :contract_end_date
      t.string :procurement_method
      t.string :procurement_method_details_en
      t.string :procurement_method_details_fr
      t.datetime :rfp_due_date
      t.string :rfp_description_en
      t.string :rfp_description_fr
      t.datetime :tender_period_start_date
      t.datetime :tender_period_end_date
      t.string :submission_method_details_en
      t.string :submission_method_details_fr
      t.string :submission_method
      t.string :eligibility_criteria_en
      t.string :eligibility_criteria_fr
      t.string :award_criteria
      t.string :award_criteria_details_en
      t.string :award_criteria_details_fr
      t.references :contact, foreign_key: true

      t.timestamps
    end
    add_index :procurements, :ocid, unique: true
    add_index :procurements, :tender_id, unique: true
  end
end
