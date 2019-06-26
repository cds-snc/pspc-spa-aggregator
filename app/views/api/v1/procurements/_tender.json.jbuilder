json.id tender.id
json.title tender.title_en
json.title_fr tender.title_fr
json.description tender.description_en
json.description_fr tender.description_fr

json.items do
  json.array! tender.items, partial: 'api/v1/procurements/item', as: :item
end

json.procuringEntity do
  json.id tender.procuring_entity.identifier
  json.name tender.procuring_entity.name_en
  json.name_fr tender.procuring_entity.name_fr

  json.address do
    json.streetAddress tender.procuring_entity.street_address
    json.locality tender.procuring_entity.city
    json.region tender.procuring_entity.province
    json.postalCode tender.procuring_entity.postal_code
  end

  json.contactPoint do
    json.name tender.contact.name
    json.email tender.contact.email
    json.telephone tender.contact.phone
    json.faxNumber tender.contact.fax
    json.url tender.contact.url

    json.availableLanguage do
      json.array! tender.contact.languages.collect { |l| l.code }
    end
  end
end

json.options tender.options_en
json.options_fr tender.options_fr

json.recurrence do
  json.description tender.recurrence_description_en
  json.description_fr tender.recurrence_description_fr

  json.dates do
    json.array! tender.recurrences,
        partial: "api/v1/procurements/recurrence_dates",
        as: :recurrence
  end
end

json.contractPeriod do
  json.startDate tender.contract_start_date
  json.endDate tender.contract_end_date
end

json.procurementMethod tender.procurement_method
json.procurementMethodDetails tender.procurement_method_details_en
json.procurementMethodDetails_fr tender.procurement_method_details_fr

if tender.rfp_due_date != nil ||
    tender.rfp_description_en != nil ||
    tender.rfp_description_fr != nil
  json.milestones do
    data = [
      {
        type: 'RFP',
        due_date: tender.rfp_due_date,
        description_en: tender.rfp_description_en,
        description_fr: tender.rfp_description_fr
      }
    ]

    json.array! data, partial: 'api/v1/procurements/milestone', as: :milestone
  end
end

json.tenderPeriod do
  json.startDate tender.tender_period_start_date
  json.endDate tender.tender_period_end_date
end

json.submissionMethod tender.submission_method
json.submissionMethodDetails tender.submission_method_details_en
json.submissionMethodDetails_fr tender.submission_method_details_fr

json.eligibilityCriteria tender.eligibility_criteria_en
json.eligibilityCriteria_fr tender.eligibility_criteria_fr

json.awardCriteria tender.award_criteria
json.awardCriteriaDetails tender.award_criteria_details_en
json.awardCriteriaDetails_fr tender.award_criteria_details_fr

json.coveredBy do
  json.array! tender.trade_agreements.collect { |a| a.name }
end
