require 'nokogiri'

module Converter

class Alberta
  def parse(input)
    doc = Nokogiri::XML(input)

    ops = []
    doc.xpath('//Opportunities/Opportunity').each do |op|
      ops << Opportunity.new
      tender = ops.last

      tender.ocid = get(op, :OpportunityGuid)
      tender.tender_id = get(op, :OpportunityGuid)
      tender.title_en = get(op, :Title)
      tender.description_en = get(op, :LongDescription)
      tender.proc_method_details_en = get(op, :ResponseSpecifics)
      tender.tender_period.start_date = get(op, :PostDateUtc)
      tender.tender_period.end_date = get(op, :CloseDateUtc)
      tender.submission_method_details_en = get(op, :SubmissionAddress)
      tender.agreements = get(op, :AgreementType).split(/\s*&\s*/)

      tender.procuring_entity.contact.name =
        "#{get(op, :ContactFirstName)} #{get(op, :ContactLastName)}"
      tender.procuring_entity.contact.phone = get(op, :ContactPhone)
      tender.procuring_entity.contact.fax = get(op, :ContactFax)
    end
    ops
  end

  private

  def get(op, name)
    op.xpath(name.to_s).text
  end
end  # Alberta

end  # Converter
