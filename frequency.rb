require 'json'

if ARGV[0].nil?
  exit 1
end

f = File.open(ARGV[0], "r")

contents = JSON.parse(f.read)

frequencies = Hash.new
contents.each do |tweet|
  words = tweet['text'].split " "
  words.each do |word|
    if frequencies.has_key?(word)
      frequencies[word] += 1
    else
      frequencies[word] = 1
    end

  end
end

frequencies = frequencies.sort_by {|key, value| value}.reverse!


frequencies.each do |key, value|
  puts key + ": " + value.to_s if value > 3
end