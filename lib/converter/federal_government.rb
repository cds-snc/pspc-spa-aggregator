require 'converter/csv'

module Converter

class FederalGovernment < Converter::CSVInput
  def process(entries)
    ops = []

    # The CSV file has multiple languages on different lines. We want to group
    # those back into a single entry so we can create the opportunities.
    grouped_entries = {}
    entries.each do |entry|
      if entry[:language] != 'English' && entry[:language] != 'Français'
        puts "Invalid language #{entry[:language]}"
        next
      end

      lang = entry[:language] == 'English' ? :en : :fr

      grouped_entries[entry[:reference_number]] ||= {}
      grouped_entries[entry[:reference_number]][lang] = entry
    end

    grouped_entries.each_pair do |uuid, values|
      [:en, :fr].each do |k|
        next if values[k].nil?

        cleanup_gsin(values[k])
        cleanup_contact(values[k])
        to_array(values[k], :region_opportunity)
        to_array(values[k], :region_delivery)
        to_array(values[k], :trade_agreement)
        to_array(values[k], :document)
        to_array(values[k], :attachment)
      end
    end

    grouped_entries.each_pair do |uuid, values|
      op = Opportunity.new
      op.ocid = values[:en][:solicitation_number]
      op.tender_id = values[:en][:solicitation_number]

      op.procuring_entity.name_en = values[:en][:procurement_entity]
      op.procuring_entity.name_fr = values[:fr][:procurement_entity]
      op.procuring_entity.addr = values[:en][:contact]

      op.title_en = values[:en][:title]
      op.title_fr = values[:fr][:title]

      op.description_en = values[:en][:description]
      op.description_fr = values[:fr][:description]

      op.proc_method_en = values[:en][:tendering_procedure]
      op.proc_method_fr = values[:fr][:tendering_procedure]

      methods = []
      methods << values[:en][:competitive_procurement_strategy] unless
        values[:en][:competitive_procurement_strategy].blank?
      methods << values[:en][:non_competitive_procurement_strategy] unless
        values[:en][:non_competitive_procurement_strategy].blank?
      op.proc_method_details_en = methods.join("\n") unless methods.empty?

      methods = []
      methods << values[:fr][:competitive_procurement_strategy] unless
        values[:fr][:competitive_procurement_strategy].blank?
      methods << values[:fr][:non_competitive_procurement_strategy] unless
        values[:fr][:non_competitive_procurement_strategy].blank?
      op.proc_method_details_fr = methods.join("\n") unless methods.empty?

      op.tender_period.end_date = DateTime.parse(values[:en][:date_closing])

      op.agreements =
        (values[:en][:trade_agreement] + values[:fr][:trade_agreement]).sort.uniq

      ops << op
    end
    ops
  end

  private

  def to_array(d, key)
    return if d[key].nil?
    d[key] = d[key].split(/\s*,\s*/)
  end

   #5133C - Waterways, Harbours, Dams and Other Water Works, 5154A - Concrete Work
  #T004KA - Media Monitoring Services
  def cleanup_gsin(d)
    data = d[:gsin]
    return if data.nil?

     idx = -1
    chunks = []
    while idx = (data.index(/([A-Z]*\d+[A-Z]+)\s+\-\s+/, idx + 1))
      chunks << idx
      idx += $1.size
    end

     ary = []
    chunks.each_with_index do |chunk, idx|
      last = idx < chunks.size - 1 ? chunks[idx + 1] - 1 : -1
      str = data[chunk..last].gsub(/,\s*$/, '')

       parts = str.split(/\s+-\s+/)
      ary << { id: parts[0], desc: parts[1] }
    end
    d[:gsin] = ary
  end

   def cleanup_contact(d)
    return if d[:contact].nil?
    parts = d[:contact].split(/\s*,\s*/)
    c = ''
    c = "#{parts.shift}, #{parts.shift}\n"
    c += parts.join("\n")
    d[:contact] = c
  end
end  # NovaScotia

end  # Converter

