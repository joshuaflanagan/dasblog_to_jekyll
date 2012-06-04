# require 'toto'
require 'prettyprinter'

class UrlRewrite
  include PrettyPrinter

  def initialize(url_transform)
    @url_transform = url_transform
  end
  
  def all_links articles
    links = {}
    links.merge! category_links articles
    links.merge! permalinks articles
    links.merge! friendly_links articles
    links.merge! date_links articles
    links.merge! comment_links articles    
    links
  end
    
  def permalinks articles
    old_articles = {}

    articles.each do |metadata|
      if metadata.Id != nil then
        old_url = "PermaLink,guid,#{metadata.Id}.aspx"
        old_articles[old_url] = @url_transform.call(metadata)
      end
    end

    old_articles
  end
  
  def friendly_links articles
    old_articles = {}

    articles.each do |metadata|
      if metadata.Id != nil then
        old_url = "#{metadata.generate_dasblog_friendly_link}.aspx"
        old_articles[old_url] = @url_transform.call(metadata)
      end
    end

    old_articles  
  end

  def category_links articles
    old_categories = {}
    articles.each do |metadata|
      if metadata.Tags != nil then
        metadata.Tags.each do |tag|
          old_url = "CategoryView,category,#{tag.gsub /\s/, "%2B"}.aspx"
          old_categories[old_url] = ""
        end
      end
    end

    old_categories
  end

  def date_links articles
    links = {}
    articles.each do |metadata|
      date = metadata.Date
      links["default,month,#{date.year}-#{pretty_int date.month}.aspx"] = "#{date.year}/#{pretty_int date.month}/"
    end
    links
  end

  def comment_links articles
    links = {}
    articles.each do |metadata|
      links["CommentView,guid,#{metadata.Id}.aspx"] = @url_transform.call(metadata)
    end
    links
  end
end

