require 'sqlite3'
require 'json'



hours_maps = {}
hours_pos = {}
hours_neg = {}
for hour in 0..23
  hours_maps[hour] = {}
  hours_pos[hour] = 0
  hours_neg[hour] = 0
end


f = File.open('sentiment_out.txt', 'r')
f.each_line do |line|
  #puts line
  parsed = JSON.parse(line)
  tweet = parsed['text']
  hour = parsed['created_at']
  if parsed['sentiment'] == 'pos'
    hours_pos[hour] += 1
  else
    hours_neg[hour] += 1
  end 
  words = tweet.split " "
  words.each do |word|
    if word[0] == '#'
      if hours_maps[hour].has_key?(word)
        hours_maps[hour][word] << tweet if not hours_maps[hour][word].include?(tweet)
      else
        hours_maps[hour][word] = [tweet]
      end
    end

  end
end

i =0
f_out = File.open('freq_out.txt', 'w+')
out_map = {}
for num,map in hours_maps
  map = map.sort_by { |key, value| value.length }.reverse!

  if ARGV[1]
    first_n = map[0..ARGV[1].to_i]
  else
    first_n = map[0..20]
  end

  out_map[num] = {}
  out_map[num]['words'] = {}
  if first_n
    puts i
    first_n.each do |key, value|
      puts key + ": " + value.length.to_s if value.length > 2
      out_map[num]['words'][key] = value[0..10]
    end
  end
  pos = neg = 0

  out_map[num]['sentiment'] = hours_pos[num].to_f/(hours_pos[num]+hours_neg[num]+1).to_f
  i += 1
end
f_out.write(JSON.pretty_generate(out_map))
