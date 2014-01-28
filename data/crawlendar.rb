require "uri"
require "net/https"
require "json"

@calendar_feeds = [
  "campus-party.com.br_8j7p9dq2fnj2pb3ig8jl0pgbvs%40group.calendar.google.com",
  "campus-party.com.br_sqmkibctf6n71mf9gkgcfgutvk%40group.calendar.google.com",
  "conteudoscomunidades%40campus-party.com.br",
  "campus-party.com.br_krqbl9dii9mppjmbem6d3ls464%40group.calendar.google.com",
  "campus-party.com.br_vq66jn45r6qpq280i5rqmhavso%40group.calendar.google.com",
  "campus-party.com.br_dvankcpsoo9ap46jaftnmpls5c%40group.calendar.google.com",
  "campus-party.com.br_g51h4uhd1l7hg158cra8pjbga8%40group.calendar.google.com",
  "campus-party.com.br_ffpg3l9ve20j9ifjts4p71h6k0%40group.calendar.google.com",
  "campus-party.com.br_clmb16l2tprnuoph8ass3oaom4%40group.calendar.google.com",
  "campus-party.com.br_evu80eej3n6bq1elelo9vvjn1o%40group.calendar.google.com",
  "campus-party.com.br_dqgcott7iq459vshe3ttks0ip8%40group.calendar.google.com",
  "campus-party.com.br_qdnmtupst3iri5mat77gire4og%40group.calendar.google.com",
  "campus-party.com.br_sbm5pftqc9lfsnfr667d0kfmug%40group.calendar.google.com",
  "campus-party.com.br_bpq3je4mahd0p9srqhdrviunqg%40group.calendar.google.com"
]


@calendar_feeds.each do |feed|

  puts "Getting feed: " + feed
  
  gdata_api_url = "https://www.google.com/calendar/feeds/" +
                  feed +
                  "/public/full-noattendees?alt=json&orderby=starttime" +
                  "&start-min=2014-01-27T00:00:00-02:00" +
                  "&start-max=2014-02-02T23:59:59-02:00" +
                  "&futureevents=true&max-results=300"

  uri = URI.parse(gdata_api_url);

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  req = Net::HTTP::Get.new(uri.request_uri)
  req["Host"] = uri.host
  response = http.request(req)

  if response.code == "200" 
    agenda = JSON.parse(response.body)

    title = agenda["feed"]["title"]["$t"]
    last_update = agenda["feed"]["updated"]["$t"]
    puts "  Calendário: " + title
    puts "  Entradas: " +  agenda["feed"]["openSearch$totalResults"]["$t"].to_s
    puts "  Atualizado em: " + last_update
    puts "  File size: #{response.body.size.to_s} bytes"
    File.open("./output/"+title.gsub(/[^\x00-\x7F]|[ -]/,"")+".json", 'w') { |file| file.write(response.body) }
  else
    puts "  Erro! #{response.code.to_s} - #{response.body}"
  end

end
