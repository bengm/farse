########
#
# Method:
# - Go to FAR web site at https://www.acquisition.gov/?q=browsefar
# - Near top of page: "Download Entire FAR" (HTML) https://www.acquisition.gov/sites/default/files/current/far/zip/html/FAC%202005-92%20HTML%20Files.zip
# - Unzip above into /html directory
#
#
########

require 'nokogiri'
require 'json'
require 'byebug'

def select_relevant_files(dir)
  files = Dir["#{dir}*"]
  files.select{|f| f.sub(dir,'').start_with? '52_', 'Subpart'}
end

def parse_page(page)
  clauses_arr = []
  debug = false
  current_clause = nil
  # all relevant nodes have a class starting with p, like pBody, pSection, etc.
  text_nodes = page.at_css('body').children.select{|n|n.attributes["class"].to_s[0]=="p"}
  text_nodes.each_with_index do |node,i|
    html_class = node.attributes["class"].to_s || ""
    puts html_class if debug
    if html_class == "pSection"
      # if we've stumbled on a new section, save the old one and start a new one
      clauses_arr << current_clause if current_clause
      current_clause = {
        number: node.content.split(" ",2).first,
        title:node.content.split(" ",2).last,
        children:[]
      }
      print " *" + current_clause[:number]
    elsif html_class == "pSubpart"
    else
      # otherwise, add the content as a child
      # TODO fix edge case for Subpart 19.11, 30.3, 30.4, 30.5
      #      (no section for the content, which is essentially empty pBody)
      #      34.1, 45.3, 45.5 have blank pBody early on (content error)
      (byebug unless current_clause) if debug
      current_clause[:children] << parse_content_node(node,html_class) if current_clause
    end
  end
  return clauses_arr
end

def parse_content_node(node,html_class)
  debug = false
  if html_class.start_with? "pBody", "pDefault" # note only 1 use of pDefault
    type  = "paragraph"
    level = nil
  else
    # TODO fix missing edge cases to handle pTableTitle, <table> without a class
    #      i.e. in 4.8
    (byebug unless html_class[0..8] == "pIndented") if debug
    type  = "outline"
    level = html_class[9].to_i
  end
  {
    text:node.content.strip,
    type:type,
    level:level
  }
end

# parse
clauses = []
select_relevant_files("html/").each do |f|
  puts " "
  puts "-----------------"
  puts f
  page = Nokogiri::HTML(open(f))
  clauses += parse_page(page)
end

# write complete file
File.open('output_data/complete_far.json', 'w') do |f|
  f.puts clauses.to_json
end
clauses.each do |clause|
  File.open("output_data/#{clause[:number]}.json", 'w') do |f|
    f.puts clause.to_json
  end
end

puts ""
puts "  ~~ FIN ~~  "
