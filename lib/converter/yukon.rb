require 'converter/csv'

module Converter

class Yukon < Converter::CSVInput
  def process(entries)
    ops = []
    entries.each do |entry|
      op = Opportunity.new
      op.ocid = entry[:TenderNo]
      op.tender_id = entry[:TenderNo]

      op.procuring_entity.name_en = entry[:Department]

      op.description_en = entry[:TenderTitle]

      op.tender_period.start_date = DateTime.parse(entry[:PublishedDate])
      op.tender_period.end_date = DateTime.parse(entry[:ClosingDate])
      ops << op
    end
    ops
  end
end  # Yukon

end  # Converter

