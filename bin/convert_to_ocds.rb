#!/usr/bin/env ruby

require 'converter'

if ARGV.size < 2
  puts "Missing options: convert_to_ocds.rb [FPT] [filename]"
  exit
end

fpt = ARGV[0].upcase.to_sym

conv = if fpt == :AB
  Converter::Alberta.new
elsif fpt == :BC
  Converter::BritishColumbia.new
elsif fpt == :GC
  Converter::FederalGovernment.new
elsif fpt == :NS
  Converter::NovaScotia.new
elsif fpt == :NU
  Converter::Nunavut.new
elsif fpt == :QC
  Converter::Quebec.new
elsif fpt == :YK
  Converter::Yukon.new
else
  puts "Unknown FPT value #{fpt}, expected one of: ab, bc, gc, ns, nu, qc, yk"
  exit
end

if !File.exists?(ARGV[1])
  puts "Invalid input file #{ARGV[1]}"
  exit
end

data = File.open(ARGV[1]).read
data.encode!('UTF-8', 'UTF-8', :invalid => :replace)

ops = conv.parse(data)

puts Converter::OCDS.ToJSON(ops)
