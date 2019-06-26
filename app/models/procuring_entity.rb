class ProcuringEntity < ApplicationRecord
  include PgSearch
  multisearchable against: %i(identifier name_en name_fr city province)

  has_many :contacts
  has_many :procurements, through: :contacts
end
