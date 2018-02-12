# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "redis/prescription/version"

Gem::Specification.new do |spec|
  spec.name          = "redis-prescription"
  spec.version       = Redis::Prescription::VERSION
  spec.authors       = ["Alexey Zapparov"]
  spec.email         = ["ixti@member.fsf.org"]

  spec.summary       = "Redis LUA stored procedure runner."
  spec.description   = <<~DESCRIPTION
    Preloads (and reloads when needed, e.g. when scripts
    were flushed away) script and then runs it with `EVALSHA`.
  DESCRIPTION

  spec.homepage      = "https://github.com/sensortower/redis-prescription"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
end
