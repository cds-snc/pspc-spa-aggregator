#!/usr/bin/env ruby

require 'converter'

if ARGV.size < 2
  puts "Missing options: convert_to_ocds.rb [ftp] [filename]"
  exit
end

ftp = ARGV[0].upcase.to_sym

conv = if ftp == :AB
  Converter::Alberta.new
elsif ftp == :BC
  Converter::BritishColumbia.new
else
  puts "Unknown ftp value #{ftp}, expected one of: ab, bc"
end

if !File.exists?(ARGV[1])
  puts "Invalid input file #{ARGV[1]}"
  exit
end

data = File.open(ARGV[1]).read
data.encode!('UTF-8', 'UTF-8', :invalid => :replace)

ops = conv.parse(data)

puts Converter::OCDS.ToJSON(ops)
