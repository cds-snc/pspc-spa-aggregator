class ProcurementItem < ApplicationRecord
  include PgSearch
  multisearchable against: %i(identifier description_en description_fr)

  belongs_to :procurement
end
