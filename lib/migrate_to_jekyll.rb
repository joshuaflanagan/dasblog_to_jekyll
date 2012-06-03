require 'urlrewrite'

class MigrateToJekyll
  def initialize(posts_path)
    if posts_path == nil then raise "_posts output path must be specified" end
    if File.directory?(posts_path) == false then raise "directory does not exists" end
    
    @posts_path = posts_path
  end
  
  def migrate(entries, include_unpublished=false)
    if entries == nil then raise "entries must be specified" end
      
    entries.each do |entry|
      next unless (entry.Published || include_unpublished)
      file = File.new("#{@posts_path}/#{entry.jekyll_filename}", "w+")
      file.puts entry.to_jekyll
    end
    
    url_rewrite = UrlRewrite.new
    file = File.new("#{@posts_path}/redirect.rb", "w+")  
    urls = url_rewrite.all_links entries
    
    urls.each do |old_url, new_url|
      file.puts "r301 '#{old_url}', '#{new_url}'"
    end    
  end
end
