require 'csv'

module Converter

class CSVInput
  def parse(input)
    csv = CSV.new(input)
    header = csv.shift.collect { |h| h.gsub(/[^a-zA-Z0-9_]/, '') }
    entries = []
    csv.each do |row|
      r = {}
      row.each_with_index do |item, idx|
        r[header[idx].to_sym] = item
      end
      entries << r
    end

    process(entries)
  end

  def process(entries)
    puts "Missing process method"
    exit
  end
end  # CSVInput

end  # Converter
