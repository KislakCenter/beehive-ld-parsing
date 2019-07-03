#!/usr/bin/env ruby
#

require 'csv'

csv_in = ARGV.shift

CSV.foreach csv_in, headers: true do |row|
  pid = row['pid']
  selection = row['selection']
  jpg = "data/images/#{pid}.jpg"
  if File.exist? jpg
    STDERR.puts "Already have #{jpg}"
  else
    STDERR.puts "Retrieving #{jpg}"
    `curl -o data/images/#{jpg} "#{selection}"` 
  end
end
