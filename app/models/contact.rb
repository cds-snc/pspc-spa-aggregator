class Contact < ApplicationRecord
  include PgSearch
  multisearchable against: %i(name email)

  belongs_to :procuring_entity
  has_many :procurements
  has_many :languages, class_name: :ContactLanguage
end
