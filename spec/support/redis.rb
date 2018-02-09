# frozen_string_literal: true

require "redis"
require "redis-namespace"

REDIS_URL = ENV.fetch("REDIS_URL", "redis://localhost/15").freeze
REDIS     = Redis.new(:url => REDIS_URL)

RSpec.configure do |config|
  redis   = Redis.new(:url => REDIS_URL)
  cleanup = proc { redis.tap(&:flushdb).script("flush") }

  config.before(&cleanup)
  config.after(:suite, &cleanup)
end
