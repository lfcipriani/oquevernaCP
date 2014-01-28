require "json"
require "time"

# pedidos possíveis de ser feito
WHEN = %w(agora depois)
# palcos do evento
TRACKS = %w(hypatia   arquimedes comunidades  crossspace 
            galileu   gutemberg  michelangelo principal 
            stadium   pitagoras  socrates     workshop1 
            workshop2 workshop3)

module OquevernaCP
  class EventSuggest
    def initialize(agenda)
      @agenda = JSON.parse(File.read(agenda))
    end

    def what_to_see?(status)
      hashtags = status.hashtags.map { |h| h.text }
      # removing invalid whens
      _when = hashtags.select { |h| WHEN.include?(h) }
      # filtering the whats
      what = hashtags - _when
      # removing invalid tracks
      what.select! { |h| TRACKS.include?(h) }

      index   = ((what.empty?) ? @agenda["index"]["general"] : @agenda["index"][what.first])
      entries = ((what.empty?) ? @agenda["general"]          : @agenda["tracks"][what.first])

      now  = Time.now.to_i
      event_next      = index.select { |x| x >= now.to_s }.first
      event_happening = index.select { |x| x <= now.to_s }.last
      
      if event_next.nil? # campus party is over
        return tweet_text(status.user.screen_name, 
                          "A Campus Party já terminou. Até o ano que vem...", 
                          nil, "http://www.campus-party.com.br/")
      else 
        event_happening = (event_happening.nil? ? 0 : event_happening.to_i )
        event_next = event_next.to_i
        # use heuristic if user have no preference of time
        if _when.empty?
          decision = ((now - event_happening <= 60*15) ? event_happening : event_next) # 15 minutes of late is acceptable
        else
          # if user wants to know what's happening now
          if _when.first == "agora"
            if event_happening == 0
              return tweet_text(status.user.screen_name, 
                                "A Campus Party ainda não começou. Tente perguntar o que vem #depois :-)", 
                                nil, "http://www.campus-party.com.br/")
            else
              decision = ((event_next - now < 60*10) ? event_next : event_happening) 
            end
          # if user wants to know what comes after
          else
            decision = event_next
          end
        end
      end

      suggestion = entries[decision.to_s].sample
      suggestion["delta"] = now - decision
      tweet_text(status.user.screen_name, suggestion["title"], suggestion["delta"], suggestion["link"])
    end

    def tweet_text(screen_name, text, delta, link)
      tweet = []
      tweet << "@#{screen_name}" if screen_name
      tweet << (delta < 0 ? "em " : "há ") + (delta.abs/60).to_s + " min" if delta
      remaining = 140 - tweet.join(" ").size + (link ? 25 : 1) # 24 chars for t.co link + 1 space required to fit text between 2 words
      if remaining < text.size
        text = text[0..remaining-3] + "..." # minus 3 due to ellipsis
      end
      tweet << link if link
      tweet.insert(1,text).join(" ")
    end

  end
end
