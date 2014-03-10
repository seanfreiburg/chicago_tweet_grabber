require 'sqlite3'
require 'json'

if ARGV[0].nil?
  exit 1
end

puts "Reading a  database called #{ARGV[0]}"

old_db = SQLite3::Database.new( ARGV[0] )
new_db = SQLite3::Database.new( ARGV[1] )
new_db.execute("DROP TABLE twitter_data;")
new_db.execute( "CREATE TABLE twitter_data (id INTEGER PRIMARY KEY AUTOINCREMENT,text TEXT, hour int, data TEXT );" )
ins = new_db.prepare('insert into twitter_data (text,hour,data) values (?,?,?)')


rows = old_db.execute("SELECT * FROM twitter_data;")
rows.each do |row|
  parsed = JSON.parse(row[1])
  hour =  parsed['created_at'].split[3].split(':')[0]
  puts parsed['text'] + hour
  ins.execute(parsed['text'], hour, row[1])
end
