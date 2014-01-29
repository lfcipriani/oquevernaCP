require "tweetstream"
require "em-http-request"
require "redis"
require "hiredis"
require "simple_oauth"
require "yaml"
require "json"
require "uri"
require "logger"
require "./event_suggest"
require "./rate_limiter"

DATA_FILE = "./data/output/the_data_you_need_to_make_magic.json"
IPOBNJ = [47, 92, 32, 47, 92, 32, 92, 47, 32, 92, 47, 32, 38, 108, 116, 59, 32, 38, 103, 116, 59, 32, 38, 108, 116, 59, 32, 38, 103, 116, 59, 32, 98, 32, 97] 
REDIS_URI = URI.parse("redis://localhost:6379")
REDIS = Redis.new(:host => REDIS_URI.host, :port => REDIS_URI.port, :password => REDIS_URI.password, :driver => :hiredis)
$stdout.sync = true
LOG = Logger.new(STDOUT)
LOG.level = Logger::DEBUG
LOG.datetime_format = '%Y-%m-%d %H:%M:%S '

OAUTH = YAML.load_file(File.expand_path("./config/credentials.yml"))
# configure tweetstream instance
TweetStream.configure do |config|
  config.consumer_key       = OAUTH[:consumer_key]
  config.consumer_secret    = OAUTH[:consumer_secret]
  config.oauth_token        = OAUTH[:token]
  config.oauth_token_secret = OAUTH[:token_secret]
  config.auth_method = :oauth
end
