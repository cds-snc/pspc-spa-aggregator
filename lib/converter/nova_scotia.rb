require 'converter/csv'

module Converter

class NovaScotia < Converter::CSVInput
  def process(entries)
    ops = []
    entries.each do |entry|
      op = Opportunity.new
      op.ocid = entry[:tender_id]
      op.tender_id = entry[:tender_id]

      op.procuring_entity.name_en = entry[:deptname]
      op.procuring_entity.contact.name = entry[:contact]

      op.description_en = "#{entry[:descript]}\n#{entry[:add_desc]}\n#{entry[:add_txt_str]}"

      op.contract_period.start_date = DateTime.strptime(entry[:start_date], '%m/%d/%Y')

      op.tender_period.start_date =
        DateTime.strptime("#{entry[:open_date]} #{entry[:open_time]}", '%m/%d/%Y %l:%M %p')
      op.tender_period.end_date =
        DateTime.strptime("#{entry[:close_date]} #{entry[:close_time]}", '%m/%d/%Y %l:%M %p')

      if entry[:threshold] == "E"
        op.agreements ||= []
        op.agreements << "CETA"
      end
      if entry[:threshold] == "W"
        op.agreements ||= []
        op.agreements << "WTO"
      end

      op.submission_method_details_en = entry[:close_loc]

      ops << op
    end
    ops
  end
end  # NovaScotia

end  # Converter
