class AddDeliveryDatesAndModalitiesToProcurements < ActiveRecord::Migration[5.2]
  def change
    add_column :procurements, :delivery_date, :datetime
    add_column :procurements, :delivery_start_date, :datetime
    add_column :procurements, :delivery_end_date, :datetime
    add_column :procurements, :use_electronic_auction, :boolean, default: false
    add_column :procurements, :is_negotiated, :boolean, default: false
  end
end
