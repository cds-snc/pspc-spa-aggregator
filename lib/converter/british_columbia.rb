module Converter

class BritishColumbia
  def parse(input)
    entries = []
    cur_tag = ''
    cur_data = ''
    input.split(/\r?\n/).each do |line|
      break if line == "<END_OF_FILE>"

      if line =~ /^<([^>]*)>$/
        if !entries.empty?
          entries.last[cur_tag] = cur_data.strip
          cur_data = ''
        end

        cur_tag = $1.to_sym
        entries << {} if cur_tag == :SOLICITATION
      else
        cur_data += "#{line}\n"
      end
    end

    ops = []
    entries.each do |entry|
      op = Opportunity.new

      op.ocid = entry[:SOLICITATION]
      op.tender_id = entry[:OPPORTUNITY_REF]

      op.procuring_entity.addr = entry[:E_DETAIL_2]
      op.procuring_entity.contact.name = entry[:CONTACT]
      op.procuring_entity.contact.phone = entry[:TELEPHONE]
      op.procuring_entity.contact.fax = entry[:FACSIMILE]

      op.title_en = entry[:E_TITLE]
      op.title_fr = entry[:F_TITLE]

      op.description_en = entry[:E_DETAIL_1]
      op.description_fr = entry[:F_DETAIL_1]

      # TODO(dsinclair): Determine if SOLIC_METHOD handling is needed.

      op.tender_period.start_date = DateTime.parse(entry[:POSTING_DATE])
      op.tender_period.end_date = DateTime.parse("#{entry[:CLOSING_DATE]} #{entry[:CLOSING_TIME]}")

      op.agreements = entry[:AGREEMENT_TYPE]

      ops << op
    end
    ops
  end
end  # BritishColumbia

end  # Converter
