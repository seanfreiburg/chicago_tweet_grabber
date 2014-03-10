require 'sqlite3'
require 'json'

if ARGV[0].nil?
  exit 1
end

puts "Reading a  database called #{ARGV[0]}"

db = SQLite3::Database.new( ARGV[0] )


f = File.new('out.txt', 'w+')
limit = 100

rows = db.execute("SELECT * FROM twitter_data;")
data = {}
rows.each do |row|
  data['text'] = row[1]
  data['created_at'] = row[2]
  #data['data'] = row[3]
  f.write(data.to_json+ "\n")
end
