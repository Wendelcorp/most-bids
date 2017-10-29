require 'nokogiri'
require 'open-uri'
require 'tty-spinner'
require 'tty-cursor'
require 'colorize'
require 'clipboard'

puts "Search for an item to see popular results"
term = gets.chomp
@spinner = TTY::Spinner.new(":spinner Parsing eBay Data ...".colorize(:light_magenta), format: :arc)
@spinner.auto_spin
link = "https://www.ebay.com/sch/" + term.downcase.tr(' ', '+') + "?isRefine=true&LH_Auction=1&_ipg=200"
page = Nokogiri::HTML(open(link))
number_of_pages = ((page.css('.rcnt').text.to_f / 200)).ceil

@items = []
i = number_of_pages
while i > 0
  new_link = link + "&_pgn=#{i}"
  page = Nokogiri::HTML(open(new_link))
  page.css('.sresult').each do |item|
    item_hash = Hash.new
    bids = item.css('.lvformat span').text.split.join(" ").gsub(/bids/, 'bid' => '', 's' => '').to_i
    item_hash['bids'] = bids
    item_hash['name'] = item.css('h3 a').text.split.join(" ")
    item_hash['url'] = item.css('h3 a')[0]["href"]
    if bids > 0
      @items << item_hash
    end
  end
  i -= 1
end

@spinner.stop("Complete".colorize(:light_cyan))
@items = @items.sort_by { |k| k["bids"] }
@items = @items.reverse
@items.each_with_index do |item, index|
  puts "[#{index}]".colorize(:light_cyan) + " Bids: " + item["bids"].to_s.colorize(:light_magenta) + " Name :" + item["name"]
end

puts ""
puts "Select a number to copy url"
selection = gets.chomp.to_i
Clipboard.copy(@items[selection]["url"])
# puts @items[selection]["url"]
puts "Copied!".colorize(:light_magenta)
