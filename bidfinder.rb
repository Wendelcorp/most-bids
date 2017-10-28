require 'nokogiri'
require 'open-uri'

puts "Search for an item to see popular results"
term = gets.chomp
link = "https://www.ebay.com/sch/" + term.gsub!(/ /, "+") + "?isRefine=true&LH_Auction=1&_ipg=200"
page = Nokogiri::HTML(open(link))

@items = []

number_of_pages = ((page.css('.rcnt').text.to_f / 200)).ceil

i = number_of_pages
while i > 0
  new_link = link + "&_pgn=#{i}"
  page = Nokogiri::HTML(open(new_link))
  page.css('.sresult').each do |item|
    item_hash = Hash.new
    bids = item.css('.lvformat span').text.split.join(" ").gsub(/bids/, 'bid' => '', 's' => '').to_i
    item_hash['bids'] = bids
    item_hash['name'] = item.css('h3 a').text.split.join(" ")
    # item_hash['item_number'] = item.css('h3 a').text.split.join(" ")
    if bids > 0
      @items << item_hash
    end
  end
  i -= 1
end

sorted = @items.sort_by { |k| k["bids"] }
puts sorted.reverse
