require 'nokogiri'

module Converter

class Quebec
  def parse(input)
    doc = Nokogiri::XML(input)

    ops = []
    doc.xpath('//export/avis').each do |op|
      ops << Opportunity.new
      tender = ops.last

      tender.ocid = get(op, :numeroseao)
      tender.tender_id = get(op, :numeroseao)
      tender.title_fr = get(op, :titre)
      tender.description_fr = get(op, :description)

      tender.tender_period.start_date = DateTime.parse(get(op, :datepublication))

      end_date = get(op, :datelimitereception)
      tender.tender_period.end_date = DateTime.parse(end_date) unless end_date.blank?

      tender.procuring_entity.name_fr = get(op, :nomorganisation)
      tender.procuring_entity.contact.name = get(op, :responsable)
    end
    ops
  end

  private

  def get(op, name)
    op.xpath(name.to_s).text
  end
end  # Alberta

end  # Converter

