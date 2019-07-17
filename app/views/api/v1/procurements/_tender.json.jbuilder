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

  json.contactPoint do
    json.name tender.contact.name unless tender.contact.name.blank?
    json.email tender.contact.email unless tender.contact.email.blank?
    json.telephone tender.contact.phone unless tender.contact.phone.blank?
    json.faxNumber tender.contact.fax unless tender.contact.fax.blank?
    json.url tender.contact.url unless tender.contact.url.blank?

    if !tender.contact.languages.empty?
      json.availableLanguage do
        json.array! tender.contact.languages.collect { |l| l.code }
      end
    end
  end
end

json.options tender.options_en unless tender.options_en.blank?
json.options_fr tender.options_fr unless tender.options_fr.blank?

if !tender.recurrence_description_en.blank? ||
    !tender.recurrence_description_fr.blank? ||
    !tender.recurrences.empty?
  json.recurrence do
    json.description tender.recurrence_description_en unless tender.recurrence_description_en.blank?
    json.description_fr tender.recurrence_description_fr unless tender.recurrence_description_fr.blank?

    if !tender.recurrences.empty?
      json.dates do
        json.array! tender.recurrences,
            partial: "api/v1/procurements/recurrence_dates",
            as: :recurrence
      end
    end
  end
end

if !tender.contract_start_date.blank? || !tender.contract_end_date.blank?
  json.contractPeriod do
    json.startDate tender.contract_start_date unless tender.contract_start_date.blank?
    json.endDate tender.contract_end_date unless tender.contract_end_date.blank?
  end
end

json.procurementMethod tender.procurement_method
json.procurementMethodDetails tender.procurement_method_details_en
json.procurementMethodDetails_fr tender.procurement_method_details_fr

modalities = []
modalities << 'electronicAuction' if tender.use_electronic_auction
modalities << 'negotiated' if tender.is_negotiated

if !modalities.empty?
  json.procurementMethodModalities modalities
end

milestones = []
if tender.rfp_due_date != nil ||
    tender.rfp_description_en != nil ||
    tender.rfp_description_fr != nil
  milestones <<
    {
      type: 'requestToParticipate',
      due_date: tender.rfp_due_date,
      description_en: tender.rfp_description_en,
      description_fr: tender.rfp_description_fr
    }
end
if tender.delivery_date != nil || tender.delivery_start_date != nil ||
    tender.delivery_end_date != nil
  data = { type: 'delivery' }
  data['dueDate'] = tender.delivery_date unless tender.delivery_date.blank?
  if !tender.delivery_start_date.blank? || !tender.delivery_end_date.blank?
    data['period'] = {}
    data['period']['startDate'] =
        tender.delivery_start_date unless tender.delivery_start_date.blank?
    data['period']['endDate'] =
        tender.delivery_end_date unless tender.delivery_end_date.blank?
  end
  milestones << data
end

if !milestones.empty?
  json.milestones do
    json.array! data, partial: 'api/v1/procurements/milestone', as: :milestone
  end
end

json.tenderPeriod do
  json.startDate tender.tender_period_start_date
  json.endDate tender.tender_period_end_date
end

json.submissionMethod tender.submission_method unless tender.submission_method.blank?
json.submissionMethodDetails tender.submission_method_details_en unless tender.submission_method_details_en.blank?
json.submissionMethodDetails_fr tender.submission_method_details_fr unless tender.submission_method_details_fr.blank?

json.eligibilityCriteria tender.eligibility_criteria_en unless tender.eligibility_criteria_en.blank?
json.eligibilityCriteria_fr tender.eligibility_criteria_fr unless tender.eligibility_criteria_fr.blank?

json.awardCriteria tender.award_criteria unless tender.award_criteria.blank?
json.awardCriteriaDetails tender.award_criteria_details_en unless tender.award_criteria_details_en.blank?
json.awardCriteriaDetails_fr tender.award_criteria_details_fr unless tender.award_criteria_details_fr.blank?

json.coveredBy do
  json.array! tender.trade_agreements.collect { |a| a.name }
end
