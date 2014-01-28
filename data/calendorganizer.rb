require "time"
require "json"

@hashes = {
  "CPBR7  Hypatia" => "hypatia",
  "CPBR7 - Arquimedes" => "arquimedes",
  "CPBR7 - Comunidades" => "comunidades",
  "CPBR7 - Cross Space" => "crossspace",
  "CPBR7 - Galileu" => "galileu",
  "CPBR7 - Gutenberg" => "gutemberg",
  "CPBR7 - Michelangelo" => "michelangelo",
  "CPBR7 - Palco Principal" => "principal",
  "CPBR7 - Palco Stadium" => "stadium",
  "CPBR7 - Pitágoras" => "pitagoras",
  "CPBR7 - Sócrates" => "socrates",
  "CPBR7 - Workshop I" => "workshop1",
  "CPBR7 - Workshop II" => "workshop2",
  "CPBR7 - Workshop III" => "workshop3"
}

@result = {
  :general => {},
  :tracks  => {},
  :index   => {
    :general => []
  }
}
# {"1223445688" => [{:title:$t, :link:type[text/html]:href, gd$when:first:startTime, }, {}] }

Dir['./output/*.json'].each do |file|

  puts "Crunching #{file}..."
  agenda = JSON.parse(File.read(file))

  title   = agenda["feed"]["title"]["$t"]
  hashtag = @hashes[title]
  puts "Calendar: #{title} - hashtag: #{hashtag}"

  track_entries = {}
  track_index   = []
  general_index = @result[:index][:general]

  agenda["feed"]["entry"].each do |entry|

    data = {}
    data["title"] = entry["title"]["$t"]
    item = entry["link"].index { |i| i["type"] == "text/html" }
    if item
      data["link"] = entry["link"][item]["href"]
    else
      data["link"] = nil
    end
    data["start"] = entry["gd$when"][0]["startTime"]

    timestamp = Time.xmlschema(data["start"]).to_i.to_s
    puts "Entry: #{data["title"]}\n       #{data["link"]}\n       #{data["start"]}\n       #{timestamp.to_s}"

    unless @result[:general][timestamp]
      @result[:general][timestamp] = []
      general_index << timestamp
    end
    @result[:general][timestamp] << data

    unless track_entries[timestamp]
      track_entries[timestamp] = []
      track_index << timestamp
    end
    track_entries[timestamp] << data
  end

  @result[:tracks][hashtag] = track_entries
  @result[:index][hashtag]  = track_index.sort!
  @result[:index][:general] = general_index.sort!
end

result_json = @result.to_json
File.open("./output/the_data_you_need_to_make_magic.json", 'w') { |file| file.write(result_json) }
puts "Done!"
