# frozen_string_literal: true

require "redis"

REDIS_URL         = ENV.fetch("REDIS_URL", "redis://localhost/15").freeze
REDIS_NAMESPACE   = ENV["REDIS_NAMESPACE"].to_s.strip
REDIS_CONNECTION  = Redis.new(:url => REDIS_URL)

REDIS =
  if REDIS_NAMESPACE.empty?
    REDIS_CONNECTION
  else
    require "redis-namespace"
    Redis::Namespace.new(REDIS_NAMESPACE, :redis => REDIS_CONNECTION)
  end

RSpec.configure do |config|
  cleanup = proc { REDIS_CONNECTION.tap(&:flushdb).script("flush") }

  config.before :suite do
    puts "***"
    puts "*** REDIS_URL=#{REDIS_URL.inspect}"
    puts "*** REDIS_NAMESPACE=#{REDIS_NAMESPACE.inspect}"
    puts "*** REDIS=#{REDIS.inspect}"
    puts "***"
  end

  config.before(&cleanup)
  config.after(:suite, &cleanup)
end
