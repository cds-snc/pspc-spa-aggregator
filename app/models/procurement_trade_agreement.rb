class ProcurementTradeAgreement < ApplicationRecord
  include PgSearch
  multisearchable against: :name

  belongs_to :procurement
end
