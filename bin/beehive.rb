#!/usr/bin/env ruby

require 'csv'
require 'pry'

data = IO.readlines(ARGV.shift).map &:strip

headers = %w(head entry topic xref index item huh)

ANNOTATION_REGEXP = %r{<http://www.w3.org/2011/content#chars>}

HEAD  = 0
ENTRY = 1
TOPIC = 2
XREF  = 3
INDEX = 4
ITEM  = 5
WHAT  = 6
LINE  = 7

CSV do |csv|
  csv << headers
  data.each do |line|
    next unless line =~ %r{<http://www.w3.org/2011/content#chars>}
    next unless line =~ /<p>/
    text = line.sub(/^[^"]+"/, '').sub(/"[^"]+$/, '').gsub(/(&nbsp;)+/, ' ').gsub(/&amp;/, '&')
    row = []
    text.gsub! /<\/?[^>]+>/, ''
    row[LINE] = [text.gsub(/\\n/, '|')]
    if text =~ /Entry:|Topic:|Xref:|Index:/i
      text.split(/\\n/).each do |bit|
        parts = bit.split(/:\s+/)
        case parts.first
        when /Entry/i
          (row[ENTRY] ||= []) << parts.last
        when /Topic/i
          (row[TOPIC] ||= []) << parts.last
        when /Xref/i
          (row[XREF]  ||= []) << parts.last
        when /Index/
          (row[INDEX] ||= []) << parts.last
        when /#item/i
          (row[ITEM]  ||= []) << parts.first
        else
          (row[WHAT] ||= []) << parts.join(' ')
        end
      end
    else
      parts = text.split(/\\n/).map &:strip
      case parts.first
      when /^see\s/i
        (row[XREF] ||= []) << parts.first
      when /#item/i
        (row[ITEM] ||= []) << parts.first
      when /^(-+\S+|[[:alpha:]]+)(\s[&[:alpha:]]+)*$/
        row[HEAD] = [parts.first]
        parts[1..-1].each do |bit|
          if bit =~ /#item/i
            (row[ITEM]  ||= []) << bit
          elsif bit =~ /^(a|\d+)\W?$/
            (row[ENTRY] ||= []) << bit
          elsif bit =~ /^see\s/i
            (row[XREF] ||= []) << bit
          else
            (row[WHAT] ||= []) << bit
          end # if bit ...
        end # parts[1..-1].each ...
      else
        row[WHAT] = parts
      end
    end

    csv << row.map { |x| (x || []).join('|')  }
  end

end