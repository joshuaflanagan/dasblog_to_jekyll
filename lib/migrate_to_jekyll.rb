require 'urlrewrite'

class MigrateToJekyll
  def initialize(posts_path, old_base = '/', new_base = '/')
    if posts_path == nil then raise "_posts output path must be specified" end
    if File.directory?(posts_path) == false then raise "directory does not exists" end
    
    @posts_path = posts_path
    @new_base = new_base
    @old_base = old_base
  end
  
  def migrate(entries, include_unpublished=false)
    if entries == nil then raise "entries must be specified" end
      
    entries.each do |entry|
      next unless (entry.Published || include_unpublished)
      file = File.new("#{@posts_path}/#{entry.jekyll_filename}", "w+")
      file.puts entry.to_jekyll
    end
    
    url_rewrite = UrlRewrite.new ->entry{ entry.jekyll_permalink }

    file = File.new("#{@posts_path}/redirect.rb", "w+")  
    urls = url_rewrite.all_links entries
    
    urls.each do |old_url, new_url|
      file.puts "r301 '#{@old_base}#{old_url}', '#{@new_base}#{new_url}'"
    end    

    guid_map = entries.each_with_object({}) do |entry, map|
      map[entry.Id.downcase] = entry.generate_dasblog_friendly_link
    end
    File.open( "#{@posts_path}/guid_to_title_map.yaml", 'w' ) do |out|
      YAML.dump guid_map, out
    end
  end
end
