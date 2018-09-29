require 'net/http'
require 'json'

$LOL_API_KEY = 'RGAPI-15b35bcb-fec5-4729-ad94-c8e18f159297'
$PATH_TO_LOCAL_JSON = './data/allMatchData.json'

stored_data_file = File.read($PATH_TO_LOCAL_JSON)
stored_data_hash = {}

begin_index = 0
end_index = 99
final_index = 3000

puts "Starting up..."

while end_index <= final_index
    puts "Fetching list for beginIdx: #{begin_index} and endIdx: #{end_index}" 
    match_list_url = "https://na1.api.riotgames.com/lol/match/v3/matchlists/by-account/217644927?beginIndex=#{begin_index.to_s}&endIndex=#{end_index.to_s}&api_key=#{$LOL_API_KEY}"
    match_list_uri = URI(match_list_url)
    match_list_response = Net::HTTP.get(match_list_uri)
    new_match_list = JSON.parse(match_list_response)
    
    for new_match in new_match_list['matches'].reverse
        match_id = new_match['gameId']
        match_data_url = "https://na1.api.riotgames.com/lol/match/v3/matches/#{match_id}?api_key=#{$LOL_API_KEY}"
        match_data_uri = URI(match_data_url)
        match_data_response = Net::HTTP.get(match_data_uri)
        new_match_data = JSON.parse(match_data_response)
        stored_data_hash[match_id] = new_match_data
        puts "\t Added match data for gameId: #{match_id}"
    end

    begin_index = end_index + 1
    end_index = begin_index + 99

    break if end_index > final_index


    puts "\nSleeping... 😴"
    sleep( ( 2 * 60 ) + 1 )
end

puts "Done fetching match data, writing to file..."

File.open($PATH_TO_LOCAL_JSON,"w") do |f|
  f.write(stored_data_hash.to_json)
end

puts "All done ✅"

system('say "all done"')
