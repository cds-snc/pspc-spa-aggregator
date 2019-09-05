require 'converter/csv'

module Converter

class Nunavut < Converter::CSVInput
  def process(entries)
    ops = []
    entries.each do |entry|
      op = Opportunity.new
      op.ocid = entry[:Ref]
      op.tender_id = entry[:Ref]

      op.procuring_entity.contact.name = entry[:ContactPerson]
      op.procuring_entity.contact.email = entry[:Email]
      op.procuring_entity.contact.phone = entry[:PhoneNumber]
      op.procuring_entity.contact.languages = [:en, :iu]

      op.description_en = entry[:Description]

      op.tender_period.start_date = DateTime.parse(entry[:IssuedDate])
      op.tender_period.end_date = DateTime.parse(entry[:ClosingDate])

      ops << op
    end
    ops
  end
end  # Nunavut

end  # Converter

