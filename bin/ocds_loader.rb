#!/usr/bin/env ruby

if ARGV.size < 1
  puts "Missing input file name"
  exit -1
end

data = File.open(ARGV[0], "r:bom|utf-8").read
ocid = JSON.parse(data)
ocid['releases'].each do |rel|
  p = Procurement.new
  p.ocid = rel['ocid']

  tender = rel['tender']
  p.tender_id = tender['id']
  p.title_en = tender['title']
  p.title_fr = tender['title_fr']
  p.description_en = tender['description']
  p.description_fr = tender['description_fr']

  if tender.has_key?('items') && tender['items'].is_a?(Array)
    tender['items'].each do |item|
      i = ProcurementItem.new
      i.identifier = item['id']
      i.description_en = item['description']
      i.description_fr = item['description_fr']
      i.quantity = item['quantity']
      i.units_en = item['units']
      i.units_fr = item['units_fr']

      p.items << i
    end
  end

  if tender.has_key?('procuringEntity')
    pe = tender['procuringEntity']

    entity = ProcuringEntity.new
    entity.identifier = pe['id']
    entity.name_en = pe['name']
    entity.name_fr = pe['name_fr']

    if pe.has_key?('address')
      entity.street_address = pe['address']['streetAddress']
      entity.city = pe['address']['locality']
      entity.province = pe['address']['region']
      entity.postal_code = pe['address']['postalCode']
    end

    contact = Contact.new
    contact.procuring_entity = entity

    if pe.has_key?('contactPoint')
      contact.name = pe['contactPoint']['name']
      contact.email = pe['contactPoint']['email']
      contact.phone = pe['contactPoint']['telephone']
      contact.fax = pe['contactPoint']['faxNumber']
      contact.url = pe['contactPoint']['url']
    end

    p.contact = contact
  end

  if tender.has_key?('recurrence')
    p.recurrence_description_en = tender['recurrence']['description']
    p.recurrence_description_fr = tender['recurrence']['description_fr']

    if tender['recurrence'].has_key?('dates') &&
        tender['recurrence']['dates'].is_a?(Array)
      tender['recurrence']['dates'].each do |date|
        rec = ProcurementRecurrence.new
        rec.start_date = date['startDate']
        rec.end_date = date['endDate']
        rec.max_date = date['maxExtentDate']
        rec.duration_in_days = date['durationInDays']

        p.recurrences << rec
      end
    end
  end

  p.options_en = tender['options']
  p.options_fr = tender['options_fr']

  if tender.has_key?('contractPeriod')
    p.contract_start_date = tender['contractPeriod']['startDate']
    p.contract_end_date = tender['contractPeriod']['endDate']
  end

  p.procurement_method = tender['procurementMethod']
  p.procurement_method_details_en = tender['procurementMethodDetails']
  p.procurement_method_details_fr = tender['procurementMethodDetails_fr']

  if tender.has_key?('milestones') && tender['milestones'].is_a?(Array)
    tender['milestones'].each do |milestone|
      next unless milestone['type'] == 'RFP'

      p.rfp_due_date = milestone['dueDate']
      p.rfp_description_en = milestone['description']
      p.rfp_description_fr = milestone['description_fr']
      break
    end
  end

  if tender.has_key?('tenderPeriod')
    p.tender_period_start_date = tender['tenderPeriod']['startDate']
    p.tender_period_end_date = tender['tenderPeriod']['endDate']
  end

  p.submission_method = tender['submissionMethod']
  p.submission_method_details_en = tender['submissionMethodDetails']
  p.submission_method_details_fr = tender['submissionMethodDetails_fr']

  p.eligibility_criteria_en = tender['eligibilityCriteria']
  p.eligibility_criteria_fr = tender['eligibilityCriteria_fr']

  p.award_criteria = tender['awardCriteria']
  p.award_criteria_details_en = tender['awardCriteriaDetails']
  p.award_criteria_details_fr = tender['awardCriteriaDetails_fr']

  if tender.has_key?('coveredBy')
    tender['coveredBy'].each do |name|
      p << ProcurementTradeAgreement.new(name: name)
    end
  end

  p.save!
end
