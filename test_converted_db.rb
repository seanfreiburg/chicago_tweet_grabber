require 'sqlite3'
require 'json'

if ARGV[0].nil?
  exit 1
end

puts "Reading a  database called #{ARGV[0]}"

db = SQLite3::Database.new( ARGV[0] )

rows = db.execute("SELECT * FROM twitter_data;")

rows.each do |row|
  p row[1..3]
end
