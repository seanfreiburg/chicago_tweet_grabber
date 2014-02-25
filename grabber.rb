require 'twitter'
require 'json'


if ARGV[0].nil?
  exit 1
end

puts "Writing to #{ARGV[0]}"
f = File.new(ARGV[0], "w+")


client = Twitter::Streaming::Client.new do |config|
  config.consumer_key = "lkQmblpx0laxwK3Faf8awQ"
  config.consumer_secret = "OJbdAVqDppfsPoTrwKTppz2MKjrA2lRDfwsi5c5A4ZY"
  config.access_token = "47758169-4alfTPkfRVdFIm3GgSbP4YWOuvGBjEZJiiwKfbHVJ"
  config.access_token_secret = "QSaGTcCivPcVh7Q5jb1l6UfnSxiD4Vn8mnd3VfaYIHWeS"
end


#client.geo_search(query: 'chicago',granularity: 'city', :result_type => "recent").each do |tweet|
#  puts tweet.inspect
#end
tweets = []
i = 0
client.filter(locations: '-91.51307899999999,36.970298,-87.01993499999999,42.508337999999995') do |object|

  if object.is_a?(Twitter::Tweet)
    puts "Writing #{object.text}"
    tweets << object.to_h
  end
  break if i >= ARGV[1].to_i
  i +=1
end

f.write(tweets.to_json)