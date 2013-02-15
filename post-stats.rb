# encoding: utf-8

# this file will extract some statistics from the WordPress post contents
# written in Ruby because I know it better, and because I think Ruby has much better text handling (including UTF8)

require 'csv'
require 'iconv'
require 'lingua'

text = File.read('wp_posts.csv')

# had some problems with UTF8 both in R and here
ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
text2 = ic.iconv(text + ' ')[0..-2]

table = CSV.parse(text2)

stats = Array.new

table.each do |item|
  comments = item[4]
  num_comments = item[4] ? item[4].split("=>").size : 0

  txt = item[3]
  images = txt.scan(/img src/).size
  links = txt.scan(/a href/).size

  txt.gsub!(/<\/?[^>]+>/,' ') # removing html tags
  length = txt.size

  report = Lingua::EN::Readability.new(txt)
  flesch = report.flesch
  words = report.num_words

  stats << [num_comments, length, words, images, links, flesch]
end

csv_string = CSV.generate do |csv|
  stats.each do |stat|
    csv << stat
  end
end

File.open('wp_stats.csv', 'w') {|f| f << csv_string}