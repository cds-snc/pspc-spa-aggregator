# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_06_26_164524) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "contact_languages", force: :cascade do |t|
    t.bigint "contact_id"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_contact_languages_on_contact_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.string "fax"
    t.string "url"
    t.bigint "procuring_entity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["procuring_entity_id"], name: "index_contacts_on_procuring_entity_id"
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.bigint "searchable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id"
  end

  create_table "procurement_items", force: :cascade do |t|
    t.string "identifier"
    t.string "description_en"
    t.string "description_fr"
    t.integer "quantity"
    t.string "units_en"
    t.string "units_fr"
    t.bigint "procurement_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["procurement_id"], name: "index_procurement_items_on_procurement_id"
  end

  create_table "procurement_recurrences", force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "max_date"
    t.integer "duration_in_days"
    t.bigint "procurement_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["procurement_id"], name: "index_procurement_recurrences_on_procurement_id"
  end

  create_table "procurement_trade_agreements", force: :cascade do |t|
    t.string "name"
    t.bigint "procurement_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_procurement_trade_agreements_on_name", unique: true
    t.index ["procurement_id"], name: "index_procurement_trade_agreements_on_procurement_id"
  end

  create_table "procurements", force: :cascade do |t|
    t.string "ocid"
    t.string "tender_id"
    t.string "title_en"
    t.string "title_fr"
    t.string "description_en"
    t.string "description_fr"
    t.string "recurrence_description_en"
    t.string "recurrence_description_fr"
    t.string "options_en"
    t.string "options_fr"
    t.datetime "contract_start_date"
    t.datetime "contract_end_date"
    t.string "procurement_method"
    t.string "procurement_method_details_en"
    t.string "procurement_method_details_fr"
    t.datetime "rfp_due_date"
    t.string "rfp_description_en"
    t.string "rfp_description_fr"
    t.datetime "tender_period_start_date"
    t.datetime "tender_period_end_date"
    t.string "submission_method_details_en"
    t.string "submission_method_details_fr"
    t.string "submission_method"
    t.string "eligibility_criteria_en"
    t.string "eligibility_criteria_fr"
    t.string "award_criteria"
    t.string "award_criteria_details_en"
    t.string "award_criteria_details_fr"
    t.bigint "contact_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_procurements_on_contact_id"
    t.index ["ocid"], name: "index_procurements_on_ocid", unique: true
    t.index ["tender_id"], name: "index_procurements_on_tender_id", unique: true
  end

  create_table "procuring_entities", force: :cascade do |t|
    t.string "identifier"
    t.string "name_en"
    t.string "name_fr"
    t.string "street_address"
    t.string "city"
    t.string "province"
    t.string "postal_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identifier"], name: "index_procuring_entities_on_identifier", unique: true
  end

  add_foreign_key "contact_languages", "contacts"
  add_foreign_key "contacts", "procuring_entities"
  add_foreign_key "procurement_items", "procurements"
  add_foreign_key "procurement_recurrences", "procurements"
  add_foreign_key "procurement_trade_agreements", "procurements"
  add_foreign_key "procurements", "contacts"
end
