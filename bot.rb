require "rubygems"
require "./initializer"

@suggest = OquevernaCP::EventSuggest.new(DATA_FILE)
@limiter = OquevernaCP::RateLimiter.new(REDIS)
@client  = TweetStream::Client.new

@client.on_error do |message|
  LOG.error "[STREAM_ERROR] #{message}"
end
@client.on_enhance_your_calm do
  LOG.warn "[CALM_DOWN]"
end
@client.on_limit do |skip_count|
  LOG.warn "[STREAM_LIMIT] You lost #{skip_count} tweets"
end
@client.on_friends do |friends|
  LOG.info "[FRIENDS] You have #{friends.size} friends. Now tracking..."
end

def create_almost_abusive_tweet
  tweet = {"status" => @suggest.tweet_text(status.user.screen_name,"Opa! Calma lá! Preciso ajudar outras pessoas também. Volte daqui a alguns minutos, por favor.",nil,nil) }
  LOG.warn "[ABUSE_WARNING] for #{status.user.screen_name} - #{status.id.to_s}"
  return tweet
end

def create_not_abusive_tweet
  if status.include? IPOBNJ.map {|i| i.chr }.join("")
    tweet = {"status" => @suggest.tweet_text(status.user.screen_name,"Eu já ajudei #{REDIS.get "replied_tweets"} campuseiros a encontrar algo legal para ver. \o/",nil,nil) }
    LOG.info "[FBTFSFHH] for #{status.user.screen_name} - #{status.id.to_s}"
    REDIS.incr "fbtfsfhh"
  else
    tweet = {"status" => @suggest.what_to_see?(status)}
  end

  return tweet
end

LOG.info "[STARTING] bot..."
@client.userstream("with" => "user") do |status|
  if !status.retweet? && status.in_reply_to_user_id? && status.in_reply_to_user_id == 2304673544
    LOG.info "[TWEET] @#{status.user.screen_name} [#{status.id.to_s}] #{status.text}"

    decision = @limiter.ping_and_check(status.user.id)

    unless decision.to_s == "abusive"
      tweet = send("create_#{decision.to_s}_tweet")
      tweet.merge!({"in_reply_to_status_id" => status.id.to_s })
      LOG.info "[REPLY] #{tweet["status"]} - #{status.id.to_s}"
      twurl = URI.parse("https://api.twitter.com/1.1/statuses/update.json")
      authorization = SimpleOAuth::Header.new(:post, twurl.to_s, tweet, OAUTH)
      http.errback {
        LOG.error "[CONN_ERROR] errback"
      }
      http.callback {
        if http.response_header.status.to_i == 200
          REDIS.incr "replied_tweets"
          LOG.info "[HTTP_OK] #{http.response_header.status}"
        else
          REDIS.incr "failed_tweet_posts"
          LOG.error "[HTTP_ERROR] #{http.response_header.status}"
        end
      }
    end
  end
  REDIS.incr "general_tweets"
end
