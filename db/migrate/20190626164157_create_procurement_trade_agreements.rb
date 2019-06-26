class CreateProcurementTradeAgreements < ActiveRecord::Migration[5.2]
  def change
    create_table :procurement_trade_agreements do |t|
      t.string :name
      t.references :procurement, foreign_key: true

      t.timestamps
    end
    add_index :procurement_trade_agreements, :name, unique: true
  end
end
