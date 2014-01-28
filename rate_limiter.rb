WINDOW_TIME   = 60*10 # 10 minutes
POSTS_ALLOWED = 8

module OquevernaCP
  class RateLimiter
    def initialize(redis)
      @redis = redis
    end

    def ping_and_check(user_id)
      decision = :abusive
      count = @redis.get rkey("count", user_id)
      if count 
        count = count.to_i
        if count < POSTS_ALLOWED
          decision = :not_abusive
        elsif count == POSTS_ALLOWED
          decision = :almost_abusive
        else
          decision = :abusive
        end
      else
        decision = :not_abusive
        @redis.multi do
          @redis.set(rkey("count", user_id), 0)
          @redis.expire(rkey("count", user_id), WINDOW_TIME)
          @redis.set(rkey("window", user_id), Time.now.to_i)
          @redis.expire(rkey("window", user_id), WINDOW_TIME)
        end
      end
      @redis.incr(rkey("count",user_id))
      return decision
    end

  private

    def rkey(param, value)
      "ratelimiter:#{param}:#{value}"
    end

  end
end

