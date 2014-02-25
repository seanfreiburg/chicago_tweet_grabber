require 'json'

if ARGV[0].nil?
  exit 1
end

f = File.open(ARGV[0], "r")

contents = JSON.parse(f.read)

puts contents.length