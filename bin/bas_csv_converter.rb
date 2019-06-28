#!/usr/bin/env ruby

require 'csv'
require 'pp'

URL="https://buyandsell.gc.ca/procurement-data/sites/procurement-data/files/csv/tpsgc-pwgsc_ao-t_a.csv"

file = if ARGV.size < 1
  open(URL, "r:bom|utf-8")
else
  File.open(ARGV[0], "r:bom|utf-8").read
end

csv = CSV.new(file)

data = {}
header = csv.shift
csv.each do |row|
  r = {}
  row.each_with_index do |item, idx|
    name = header[idx].to_sym
    r[name] = item
  end
  r[:language] = (r[:language] == 'English') ? :en : :fr
  data[r[:reference_number]] ||= {}
  data[r[:reference_number]][r[:language]] = r
end

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

data.each_pair do |uuid, values|
  [:en, :fr].each do |k|
    cleanup_gsin(values[k])
    cleanup_contact(values[k])
    to_array(values[k], :region_opportunity)
    to_array(values[k], :region_delivery)
    to_array(values[k], :trade_agreement)
    to_array(values[k], :document)
    to_array(values[k], :attachment)
  end
end

releases = []
data.each_pair do |uuid, values|
  if !values.has_key?(:en) || !values.has_key?(:fr)
    pp values
    next
  end

   pe = {
    id: values[:en][:procurement_entity],
    name: values[:en][:procurement_entity],
    name_fr: values[:fr][:procurement_entity],
    address: {
      streetAddress: values[:en][:contact]
    }
  }

  tender = {
    id: values[:en][:solicitation_number],
    title: values[:en][:title],
    title_fr: values[:fr][:title],
    description: values[:en][:description],
    description_fr: values[:fr][:description],
    procurementMethod: values[:en][:tendering_procedure],
    procurementMethod_fr: values[:fr][:tendering_procedure],
    procurementMethodDetails:
      "#{values[:en][:competitive_procurement_strategy]}\n" +
      "#{values[:en][:non_competitive_procurement_strategy]}",
    procurementMethodDetails_fr:
      "#{values[:fr][:competitive_procurement_strategy]}\n" +
      "#{values[:fr][:non_competitive_procurement_strategy]}",
    procuringEntity: pe,
    tenderPeriod: {
      endDate: values[:en][:date_closing]
    },
    coveredBy: values[:en][:trade_agreement],
    coveredBy_fr: values[:fr][:trade_agreement]
  }

   releases << {
    ocid: uuid,
    initiationType: 'tender',
    language: 'en',
    tender: tender
  }
end

 json = {
  publisher: 'BuyAndSell CSV Converter',

   license: 'http://open.canada.ca/en/open-government-licence-canada',
   license_fr: 'http://ouvert.canada.ca/fr/licence-du-gouvernement-ouvert-canada',

   extensions: %w(
    https://github.com/open-contracting-extensions/ocds_options_extension
    https://github.com/open-contracting-extensions/ocds_recurrence_extension
    https://github.com/open-contracting-extensions/ocds_additionalContactPoints_extension
    https://github.com/open-contracting-extensions/ocds_coveredBy_extension
  )
}
json[:releases] = releases

 pp json
