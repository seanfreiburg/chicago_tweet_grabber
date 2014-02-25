require 'sqlite3'
require 'json'

if ARGV[0].nil?
  exit 1
end

puts "Reading a  database called #{ARGV[0]}"

db = SQLite3::Database.new(ARGV[0])


frequencies = Hash.new
rows = db.execute("SELECT * FROM twitter_data;")
rows.each do |row|
  parsed = JSON.parse(row[1])
  tweet = parsed['text']
  words = tweet.split " "
  words.each do |word|
    if frequencies.has_key?(word)
      frequencies[word] += 1
    else
      frequencies[word] = 1
    end

  end
end

frequencies = frequencies.sort_by { |key, value| value }.reverse!

if ARGV[1]
  first_n = frequencies[0..ARGV[1].to_i]
else
  first_n = frequencies[0..20]
end


first_n.each do |key, value|
  puts key + ": " + value.to_s if value > 3
end