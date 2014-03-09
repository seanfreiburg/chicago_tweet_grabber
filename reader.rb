require 'sqlite3'
require 'json'

if ARGV[0].nil?
  exit 1
end

puts "Reading a  database called #{ARGV[0]}"

db = SQLite3::Database.new( ARGV[0] )


f = File.new('out.txt', 'w+')
limit = 100

rows = db.execute("SELECT * FROM twitter_data LIMIT #{limit};")
rows.each do |row|
  parsed = JSON.parse(row[1])
  puts parsed['text']
  f.write(parsed['text'] + "\n")
end
