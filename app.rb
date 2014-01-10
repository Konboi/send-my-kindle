require 'nokogiri'
require 'open-uri'
require 'gmail'
require 'json'
require 'mysql2'
require 'mysql2-cs-bind'

URL = "http://b.hatena.ne.jp/hotentry/it"
$config = JSON.parse(IO.read(File.dirname(__FILE__) + "/config/settings.json"))

targets = ["ruby", "rails", "aws", "vim", "tmux"]

def database
  return $mysql if $mysql
  $mysql = Mysql2::Client.new(
    :host      => $config["db"]["host"],
    :port      => $config["db"]["port"],
    :username  => $config["db"]["username"],
    :password  => $config["db"]["password"],
    :database  => $config["db"]["dbname"],
    :reconnect => true,
    )
end

def store_html(entry)
  entry_html = Nokogiri::HTML(open(entry[:link]))

  File.open("tmp/#{entry[:title]}.html", "w") do |file|
    file.puts(entry_html)
  end
end


def send_kindle(entry)
  puts "send: #{entry[:title]}"
  gmail = Gmail.connect($config["gmail"]["username"], $config["gmail"]["password"])
  gmail.deliver do
    to $config["kindle"]["email"]
    subject "変換"
    text_part do
      body 'send to kindle'
    end
    add_file "./tmp/#{entry[:title]}.html"
  end

  db = database
  db.xquery(
    "INSERT INTO articles (url, title) VALUES (?, ?)",
    entry[:link], entry[:title]
  )
end

# Get article by hatena bookamrk category id
entries = []
doc = Nokogiri::HTML(open(URL))
doc.css('li.entry-unit.category-it').each do |article|
  entry = {}
  link = article.css('h3.hb-entry-link-container a').first
  entry[:title] = link.text
  entry[:link] = link.attribute('href')
  entry[:tags] = []

  article.css('li.tag a').each do |tag|
    entry[:tags].push(tag.text.downcase)
  end
  entries.push(entry)
end


entries.each do |entry|
  db = database
    targets.each do |target|
    if entry[:tags].include?(target)
      next if db.xquery('SELECT * FROM articles WHERE articles.url = ?', entry[:link]).first
      store_html(entry)
      send_kindle(entry)
      File.delete("tmp/#{entry[:title]}.html")
    end

  end
end
