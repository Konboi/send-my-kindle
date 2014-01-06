require 'nokogiri'
require 'open-uri'
require 'mysql2'
require 'mysql2-cs-bind'

URL = "http://b.hatena.ne.jp/hotentry/it"
targets = ["ruby", "Ruby", "Rails", "AWS", "vim"]

def store_html(entry)
  entry_html = Nokogiri::HTML(open(entry['link']))

  File.open("tmp/store.html", "w") do |file|
    file.puts(entry_html)
  end
end


# Get article by hatena bookamrk category id
entries = []
doc = Nokogiri::HTML(open(URL))
doc.css('li.entry-unit.category-it').each do |article|
  entry = {}
  link = article.css('h3.hb-entry-link-container a').first
  entry['title'] = link.text
  entry['link'] = link.attribute('href')
  entry['tags'] = []

  article.css('li.tag a').each do |tag|
    entry['tags'].push(tag.text)
  end
  entries.push(entry)
end


entries.each do |entry|
  targets.each do |target|
    store_html(entry) if entry["tags"].include?(target)
  end
end
