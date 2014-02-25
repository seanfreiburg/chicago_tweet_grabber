require 'sqlite3'

if ARGV[0].nil?
  exit 1
end

puts "creating databse called #{ARGV[0]}"

db = SQLite3::Database.new( ARGV[0] )

db.execute("DROP TABLE twitter_data;")
db.execute( "CREATE TABLE twitter_data (id INTEGER PRIMARY KEY AUTOINCREMENT,data TEXT);" )

#db.execute("INSERT INTO twitter_data (data)
#VALUES ('Paul');")

#rows = db.execute("SELECT * FROM twitter_data;")
#p rows