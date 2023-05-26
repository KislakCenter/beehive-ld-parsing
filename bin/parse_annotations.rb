#!/usr/bin/env ruby

require 'strscan'
require 'open-uri'
require 'set'
require 'jsonpath'
require 'csv'
require 'pp'

require 'htmlentities'
require 'rdf'
require 'sparql/client'

##
# Script to read and parse Bee Hive annotation linked data and convert it to
# CSV format. Output CSV data looks like the following.
#
#     volume,image_number,head,entry,topic,xref,index,item,unparsed,line,selection,full_image
#     Volume 1,455,,Execution,Execution,,execution,#item-a147ed4b8,,Entry: Execution|Topic: Execution|Index: execution|#item-a147ed4b8,"https://stacks.stanford.edu/image/iiif/ps974xt6740%2F1607_0454/347,288,3070,287/full/0/default.jpg",https://stacks.stanford.edu/image/iiif/ps974xt6740%2F1607_0454/full/full/0/default.jpg
#     Volume 1,455,,Exercise,Exercise,1345 [Exercise],exercise,#item-d845c95d0,,Entry: Exercise|Topic: Exercise|XRef: 1345 [Exercise]|Index: exercise|#item-d845c95d0,"https://stacks.stanford.edu/image/iiif/ps974xt6740%2F1607_0454/373,602,3055,237/full/0/default.jpg",https://stacks.stanford.edu/image/iiif/ps974xt6740%2F1607_0454/full/full/0/default.jpg
#     Volume 1,455,,Exorcism,Exorcism,Conjuration|1541 [Conjuring]|1551 [Gafers],exorcism,#item-a42a0b906,,Entry: Exorcism|Topic: Exorcism|XRef: Conjuration|XRef: 1541 [Conjuring]|XRef: 1551 [Gafers]|Index: exorcism|#item-a42a0b906,"https://stacks.stanford.edu/image/iiif/ps974xt6740%2F1607_0454/370,851,3093,235/full/0/default.jpg",https://stacks.stanford.edu/image/iiif/ps974xt6740%2F1607_0454/full/full/0/default.jpg
#     Volume 1,455,,Experience,Experience,Skill|1345 [Experience],experience,#item-5d82b5199,,Entry: Experience|Topic: Experience|XRef: Skill|XRef: 1345 [Experience]|Index: experience|#item-5d82b5199,"https://stacks.stanford.edu/image/iiif/ps974xt6740%2F1607_0454/378,1093,3098,562/full/0/default.jpg",https://stacks.stanford.edu/image/iiif/ps974xt6740%2F1607_0454/full/full/0/default.jpg
#     ...
#     Volume 2,285,,1406,adultery,,,#item-5c8343e31,,Entry: 1406|Topic: adultery|#item-5c8343e31,"https://stacks.stanford.edu/image/iiif/fm855tg5659%2F1607_0752/332,204,2931,519/full/0/default.jpg",https://stacks.stanford.edu/image/iiif/fm855tg5659%2F1607_0752/full/full/0/default.jpg
#     Volume 2,285,,1408,Acceptable,,,#item-5ee82cb32,,Entry: 1408|Topic: Acceptable|#item-5ee82cb32,"https://stacks.stanford.edu/image/iiif/fm855tg5659%2F1607_0752/285,2096,3028,583/full/0/default.jpg",https://stacks.stanford.edu/image/iiif/fm855tg5659%2F1607_0752/full/full/0/default.jpg
#     Volume 2,288,,1421,Atheism,1983,Atheism,#item-b2f1c1590,,Entry: 1421|Topic: Atheism|Index: Atheism|Xref: 1983|#item-b2f1c1590,"https://stacks.stanford.edu/image/iiif/fm855tg5659%2F1607_0755/864,254,2909,732/full/0/default.jpg",https://stacks.stanford.edu/image/iiif/fm855tg5659%2F1607_0755/full/full/0/default.jpg
#     ...
#     Volume 3,47,term of life presint,4515 [PAGE_MISSING],,,,#item-fb43076d5,,Head: term of life presint|Entry: 4515 [PAGE_MISSING]|#item-fb43076d5,"https://stacks.stanford.edu/image/iiif/gw497tq8651%2F1607_0990/165,2473,732,89/full/0/default.jpg",https://stacks.stanford.edu/image/iiif/gw497tq8651%2F1607_0990/full/full/0/default.jpg
#     Volume 3,47,terms,537 [WORD_ILLEGIBLE]|1364 [Casuists],,,,#item-621de2bf5,,Head: terms|Entry: 537 [WORD_ILLEGIBLE]|Entry: 1364 [Casuists]|#item-621de2bf5,"https://stacks.stanford.edu/image/iiif/gw497tq8651%2F1607_0990/162,2607,564,76/full/0/default.jpg",https://stacks.stanford.edu/image/iiif/gw497tq8651%2F1607_0990/full/full/0/default.jpg
#     Volume 3,47,terra sigillata,1168 [Terra Sigillata],,,,#item-4b780e579,,Head: terra sigillata|Entry: 1168 [Terra Sigillata]|#item-4b780e579,"https://stacks.stanford.edu/image/iiif/gw497tq8651%2F1607_0990/152,2645,594,146/full/0/default.jpg",https://stacks.stanford.edu/image/iiif/gw497tq8651%2F1607_0990/full/full/0/default.jpg
#     Volume 3,47,terrour,a|669 [Terrrour]&nbsp;,,,,#item-489021159,,Head: terrour|Entry: a|Entry: 669 [Terrrour]&nbsp;|#item-489021159,"https://stacks.stanford.edu/image/iiif/gw497tq8651%2F1607_0990/164,2777,483,141/full/0/default.jpg",https://stacks.stanford.edu/image/iiif/gw497tq8651%2F1607_0990/full/full/0/default.jpg
#     ...
#

##
# First we read the manifests to get the canvas, title, and image data.
#
manifests = %w{ https://purl.stanford.edu/ps974xt6740/iiif/manifest.json
  https://purl.stanford.edu/fm855tg5659/iiif/manifest.json
  https://purl.stanford.edu/gw497tq8651/iiif/manifest.json }

##
# Class to represent the book title, canvas and image URL,
# image number, value.
class CanvasData
  attr_accessor :title, :canvas_url, :image_url

  def initialize title, canvas_url, image_url
    @title        = title
    @canvas_url   = canvas_url
    @image_url    = image_url
  end

  def volume
    title.strip =~ /volume \d+$/i && $&
  end

  def image_number
    canvas_url.split(/_/).last
  end
end

CANVAS_DB  = {}
manifests.each do |manifest|
  json    = URI.open(manifest).read.split($/).map { |line|
    # #gsub => newer stanford manifests change the canvas IDs, which is very
    # bad. Fix these by removing string like.
    #
    # Bad URL: `https://purl.stanford.edu/ps974xt6740/iiif/canvas/cocina-fileSet-ps974xt6740-ps974xt6740_1`
    #
    # Good URL: `https://purl.stanford.edu/ps974xt6740/iiif/canvas/ps974xt6740_1`
    #
    # Remove: `cocina-fileSet-ps974xt6740-` and similar
    line.gsub /cocina-fileSet-[^-]+-/, ''
  }.join $\
  # get the volume number from the title
  title   = JsonPath.on(json, 'metadata[?(@.label == "Title")].value').first

  # For each canvas get the URL of the canvas and the image, and the number of
  # image
  JsonPath.on(json, '$..canvases').first.each do |canvas|
    canvas_url = canvas['@id']
    image_url  = canvas['images'].first.dig('resource', '@id')
    CANVAS_DB[canvas_url] = CanvasData.new title, canvas_url, image_url
  end
end

##
# Find the struct of canvas data for the image for given canvas.
#
# @param [String] canvas_url
# @return [CanvasData] struct of canvas data
def find_canvas_data canvas_url
  CANVAS_DB[canvas_url]
end

HEADERS = %i{ volume image_number head entry topic page add xref see index item unparsed line selection full_image annotation_uri }

##
# Parse the content of an annotation
# @param [String] content object of annotation body's 'http://www.w3.org/2011/content#Chars'
# @return [Hash] parsed data
def parse_content content
  row = {}
  content = content.gsub('<br />', '|').gsub(/<\/?[^>]+>/, '').gsub(/\n/, '|').gsub('&nbsp;', ' ').strip
  content = HTMLEntities.new.decode content
  row[:line] = [content]
  if content =~ /Entry:|Head:/i
    content.split(/\|/).map(&:strip).each do |bit|
      head, val = bit.split(/:\s*/, 2)
      val = val.to_s.strip
      case head
      when /^Head/i
        (row[:head] ||= []) << val
      when /^Entry/i
        (row[:entry] ||= []) << val
      when /^Topic/i
        (row[:topic] ||= []) << val
      when /^Page/i
        (row[:page] ||= []) << val
      when /^Add/i
        (row[:add] ||= []) << val
      when /^Xref/i
        (row[:xref] ||= []) << val
      when /^Index/
        (row[:index] ||= []) << val
      when /^See$/i
        (row[:see] ||= []) << val
      when /^See\s/i
        # binding.pry if content =~ /brave/
        (row[:see] ||=[]) << head.split(/\s+/, 2).last.to_s.strip
      when /^#item/i
        (row[:item]   ||= []) << head.to_s.strip
      else
        (row[:unparsed] ||= []) << [head, val].join(' ').strip
      end
    end
  else
    row[:unparsed] =  content.split(/\|/).map &:strip
  end

  row.each { |k,v| row[k] = (v || []).join '|' }
  row
end


# Query to select the annotation URL, annotation chars, canvas and image
# selector coordinates
content = RDF::Vocabulary.new 'http://www.w3.org/2011/content#'
oa      = RDF::Vocabulary.new 'http://www.w3.org/ns/oa#'

sparql  = SPARQL::Client.new('http://localhost:3030/beehive')

# Updated query to accommodate older and newer annotations exported from SAS
# The difference is that the newer annotations have selector type == oa:Choice
# as opposed to oa:FragmentSelector.
#
# The newer selectors also link to coordinates via oa:default/rdf:value as
# opposed to a simple rdf:value as before. This query works with either path.
query = <<EOF
PREFIX re: <http://www.w3.org/2000/10/swap/reason#>
PREFIX oh: <http://semweb.mmlab.be/ns/oh#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX content: <http://www.w3.org/2011/content#>
SELECT ?annotation ?content ?canvas ?coordinates WHERE {
  VALUES (?selector_type) { (oa:FragmentSelector) (oa:Choice) }
  ?annotation a oa:Annotation;
              oa:hasBody ?body ;
              oa:hasTarget ?target .
  ?body content:chars ?content .
  ?target oa:hasSource ?canvas ;
          oa:hasSelector ?selector .
  ?selector a ?selector_type ;
          oa:default*/rdf:value ?coordinates .
}
EOF

result = sparql.query(query)

##
# Print CSV to standard out
CSV headers: true do |csv|
  csv << HEADERS
  csv << { volume: 'Volume 0', image_number: 0, unparsed: 'Force Google Sheets to read CSV as UTF-8: büngt; if UTF-8 occurs too late, CSV will be read as ASCII' }
  result.each_solution do |solution|
    canvas_url            = solution[:canvas].value
    canvas_data           = find_canvas_data canvas_url
    unless canvas_data
      $stderr.puts "WARNING: Canvas not found #{canvas_url}"
      next
    end
    row                   = parse_content solution[:content].value
    coordinates           = solution[:coordinates] && solution[:coordinates].value.split(/=/).last
    row[:volume]          = canvas_data.volume
    row[:image_number]    = canvas_data.image_number
    row[:selection]       = canvas_data.image_url.sub /full/, coordinates
    row[:full_image]      = canvas_data.image_url
    row[:annotation_uri]  = solution[:annotation].value
    csv << row
  end
end
