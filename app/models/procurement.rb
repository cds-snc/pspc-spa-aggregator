class Procurement < ApplicationRecord
  include PgSearch
  multisearchable against: %i(ocid tender_id title_en title_fr description_en
      description_fr recurrence_description_en recurrence_description_fr
      options_en options_fr procurement_method procurement_method_details_en
      procurement_method_details_fr rfp_description_en rfp_description_fr
      submission_method_details_en submission_method_details_fr
      submission_method eligibility_criteria_en eligibility_criteria_fr
      award_criteria award_criteria_details_en award_criteria_details_fr)

  belongs_to :contact

  has_many :items, class_name: :ProcurementItem
  has_many :recurrences, class_name: :ProcurementRecurrence
  has_many :trade_agreements, class_name: :ProcurementTradeAgreement

  def procuring_entity
    contact.procuring_entity
  end

end
