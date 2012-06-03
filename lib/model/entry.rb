# coding: utf-8
require 'htmlentities'
require 'prettyprinter'

class Entry
  include PrettyPrinter
  attr_accessor :Id
  attr_accessor :Date
  attr_accessor :Title
  attr_accessor :Content
  attr_accessor :Tags
  attr_accessor :Author
  attr_accessor :Published

  def initialize(args = nil)
    self.Tags = []
    if args != nil then 
      self.Title = args[:title]
      self.Date = args[:date]
    end
  end
  
  def toto_filename
    if self.Title == nil then raise "Title is missing" end
    if self.Date == nil then raise "Date is missing" end

    filename = "#{pretty_print_date(self.Date)}-#{generate_valid_filename(self.Title)}.txt"
    filename.downcase!
    
    filename
  end

  def jekyll_filename
    if self.Title == nil then raise "Title is missing" end
    if self.Date == nil then raise "Date is missing" end

    filename = "#{pretty_print_date(self.Date)}-#{generate_valid_filename(self.Title)}.html"
    filename.downcase!
    
    filename
  end
  
  def toto_date
    "#{self.Date.year}/#{pretty_int self.Date.month}/#{pretty_int self.Date.mday}"
  end
  
  def pretty_print_date(date)
    "#{self.Date.year}-#{pretty_int self.Date.month}-#{pretty_int self.Date.mday}"
  end
  
  def generate_valid_filename(str)
    result = remove_html_encoding(self.Title)
    result = result.strip
    result.gsub!(/\s/, "-")    
    result.gsub!(/(\$|\!|\&|\#|\||\/|\@|;|\.|,|\?|\:|”|\"|’|\'|\(|\)|…)/, "")
    result
  end
  
  def generate_dasblog_friendly_link
      result = remove_html_encoding(self.Title)
      result = result.strip
      result.gsub!(/^[a-z]|\s+[a-z]/) { |a| a.upcase }      
      result.gsub!(/\s/, "")
      result.gsub!(/(\$|\!|\&|\#|\||\/|\@|;|\.|,|\?|\:|”|\"|’|\'|\(|\)|…)/, "") 
      result
  end
  
  def to_yaml
    id = "id: #{self.Id}"
    title = "title: \"#{remove_html_encoding(self.Title.strip).gsub /\"/, "\\\""}\""
    author = "author: #{self.Author}"
    date = "date: #{toto_date}"
    tags_str = ""
    self.Tags.each do |tag| tags_str << tag << ";" end
    "#{title}\n#{author}\n#{date}\n#{id}\ntags: #{tags_str.gsub /;$/, ""}\n\n#{self.Content}"
  end
  
  def to_jekyll
    headers = {
      'title' => remove_html_encoding(self.Title.strip),
      'permalink' => "#{generate_dasblog_friendly_link}.html",
      'layout' => 'migrated',
      'date' => self.Date.to_date,
      'id' => self.Id,
      'published_at' => self.Date.to_time,
    }
    headers['tags'] = self.Tags.join(';') if self.Tags.any?
    headers['published'] = false unless self.Published

    "#{headers.to_yaml}
---

#{self.Content}"
  end
  
  def remove_html_encoding(content)
    content.gsub! /(&ndash;|&amp;ndash;)/, "-"
    content.gsub! /&amp;/, "&"
    content.gsub! /(&hellip;|&amp;hellip;)/, "..."
    
    coder = HTMLEntities.new
    result = coder.decode(content)
    
    result
  end
end
