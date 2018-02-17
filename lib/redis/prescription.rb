# frozen_string_literal: true

require_relative "prescription/version"

# @see https://github.com/redis/redis-rb
class Redis
  # Lua script executor for redis.
  #
  # Instead of executing script with `EVAL` everytime - loads script once
  # and then runs it with `EVALSHA`.
  #
  # @example Usage
  #
  #     script = Redis::Prescription.new("return ARGV[1] + ARGV[2]")
  #     script.eval(Redis.current, :argv => [2, 2]) # => 4
  class Prescription
    # Script load command.
    LOAD = "load"
    private_constant :LOAD

    # Redis error fired when script ID is unkown.
    NOSCRIPT = "NOSCRIPT"
    private_constant :NOSCRIPT

    # LUA script source.
    # @return [String]
    attr_reader :source

    # LUA script SHA1 digest.
    # @return [String]
    attr_reader :digest

    # Create a new Prescription instance.
    # @param source [#to_s] Lua script.
    def initialize(source)
      @source = source.to_s.strip.freeze
      @digest = Digest::SHA1.hexdigest(@source).freeze
    end

    # Loads script to redis.
    # @param redis [Redis, Redis::Namespace, #redis]
    # @return [void]
    def bootstrap!(redis)
      redis  = redis.redis if redis.respond_to? :redis
      digest = redis.script(LOAD, @source)
      return if @digest == digest

      # XXX: this may happen **ONLY** if script digesting will be
      #   changed in redis, which is not likely gonna happen.
      warn "[#{self.class}] Unexpected digest: " \
        "#{digest.inspect} (expected: #{@digest.inspect})"

      @digest = digest.freeze
    end

    # Executes script and returns result of execution.
    # @param redis [Redis, Redis::Namespace, #redis]
    # @param keys [Array] keys to pass to the script
    # @param argv [Array] arguments to pass to the script
    # @return depends on the script
    def eval(redis, keys: [], argv: [])
      redis.evalsha(@digest, keys, argv)
    rescue => e
      raise unless e.message.include? NOSCRIPT

      bootstrap!(redis)
      redis.evalsha(@digest, keys, argv)
    end

    # Reads given file and returns new {Prescription} with its contents.
    # @param file [String]
    # @return [Prescription]
    def self.read(file)
      new File.read file
    end
  end
end
