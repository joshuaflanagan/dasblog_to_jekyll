require 'date'
require 'rexml/document'
require 'model/entry'

class Dasblog

  def initialize(path, replacements={})
    @path = path + "content"
    @replacements = replacements        
  end
  
  def entries
    @entries ||=
     begin
       entries = []
       entry_files = Dir.glob(File.join(@path, "*.dayentry.xml"))
       entry_files.each do |f|
         comment_file = f.gsub(/\.dayentry\./, ".dayfeedback.")
         day_comments = parse_comments(comment_file)
         File.open f do |stream|
           xml = REXML::Document.new(stream)
           xml.root.elements.each("Entries/Entry") do |post_xml|
             entry = parse_entry(post_xml)
             entry.comments = day_comments[entry.Id].sort_by{|c| c["created"]}
             entries.push entry
           end
         end
       end
       entries
     end
  end
  
  def parse_entry(post_xml)
    entry = Entry.new
    entry.Id = post_xml.elements["EntryId"].text
    entry.Title = post_xml.elements["Title"].text
    entry.Content = post_xml.elements["Content"].text
    entry.Published = post_xml.elements["IsPublic"].text == "true"
    
    if(post_xml.elements["Categories"] && post_xml.elements["Categories"].text != nil)
      entry.Tags = post_xml.elements["Categories"].text.split(";")
    end
    entry.Date = DateTime.parse post_xml.elements["Created"].text
    
    @replacements.each do |regex,replace|
      entry.Content = entry.Content.gsub(regex, replace)
    end
    
    entry
  end

  def parse_comments(comment_file)
    day_comments = Hash.new(){|h,k| h[k] = []}
    return day_comments unless File.exists? comment_file
    File.open comment_file do |stream|
      xml = REXML::Document.new(stream)
      xml.root.elements.each("Comments/Comment") do |comment_xml|
        entry = comment_xml.elements["TargetEntryId"].text.downcase
        if should_publish_comment?(comment_xml)
          comment = {}
          comment["created"] = DateTime.parse(xmltext(comment_xml,"Created")).to_time
          xmltext(comment_xml,"Author").tap{|val| comment["author"] = val if val}
          xmltext(comment_xml,"AuthorEmail").tap{|val| comment["email"] = val if val}
          xmltext(comment_xml,"AuthorHomepage").tap{|val| comment["url"] = val if val}
          comment["content"] = xmltext(comment_xml,"Content")
          day_comments[entry] << comment
        end
      end
    end
    day_comments
  end

  def xmltext(element, key)
    node = element.elements[key]
    return nil unless node
    return nil unless node.text
    inner = node.text.strip
    return nil if inner.empty?
    inner
  end

  def should_publish_comment?(comment_xml)
    return false unless xmltext(comment_xml,"IsPublic") == "true"
    ["NotSpam", "NotChecked"].include?(xmltext(comment_xml,"SpamState"))
  end
end
