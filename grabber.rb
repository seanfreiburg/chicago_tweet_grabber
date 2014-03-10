require 'twitter'
require 'json'
require 'sqlite3'


if ARGV[0].nil?
  exit 1
end

puts "Writing to #{ARGV[0]}"

db = SQLite3::Database.new( ARGV[0] )


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

ins = db.prepare('insert into twitter_data (text,hour,data) values (?,?,?)')


client.filter(locations: '-91.51307899999999,36.970298,-87.01993499999999,42.508337999999995') do |object|

  if object.is_a?(Twitter::Tweet)
    puts object.text
    hour =  object.created_at.hour
    ins.execute(object.text, hour, object.to_h.to_json.to_s)
  end
  break if  ARGV[1] == 'limit' && i >= ARGV[2].to_i
  i +=1
end
