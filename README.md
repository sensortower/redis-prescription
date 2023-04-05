# ⚠️ NOTE: This project is now officially maintained [here](https://gitlab.com/ixti/redis-prescription/) ⚠️

# Redis::Prescription

[![Build Status](https://travis-ci.org/sensortower/redis-prescription.svg?branch=master)](https://travis-ci.org/sensortower/redis-prescription)
[![codecov](https://codecov.io/gh/sensortower/redis-prescription/branch/master/graph/badge.svg)](https://codecov.io/gh/sensortower/redis-prescription)
[![Maintainability](https://api.codeclimate.com/v1/badges/c816417574c1b8b64d81/maintainability)](https://codeclimate.com/github/sensortower/redis-prescription/maintainability)
[![Inline docs](http://inch-ci.org/github/sensortower/redis-prescription.svg?branch=master)](http://inch-ci.org/github/sensortower/redis-prescription)

Redis LUA stored procedure runner. Preloads (and reloads when needed, e.g. when
scripts were flushed away) script and then runs it with `EVALSHA`.


## Installation

Add this line to your application's Gemfile:

```ruby
gem "redis-prescription"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install redis-prescription


## Usage

``` ruby
script = Redis::Prescription.new <<~LUA
  return tonumber(redis.call('GET', KEYS[1]) or 42)
LUA

script.eval(Redis.current, :xxx) # => 42

Redis.current.set(:xxx, 123)
script.eval(Redis.current, :xxx) # => 123
```


## Supported Ruby Versions

This library aims to support and is [tested against][travis-ci] the following
Ruby and Redis client versions:

* Ruby
  * 2.3.x
  * 2.4.x
  * 2.5.x

* [redis-rb](https://github.com/redis/redis-rb)
  * 4.x

* [redis-namespace](https://github.com/resque/redis-namespace)
  * 1.6


If something doesn't work on one of these versions, it's a bug.

This library may inadvertently work (or seem to work) on other Ruby versions,
however support will only be provided for the versions listed above.

If you would like this library to support another Ruby version or
implementation, you may volunteer to be a maintainer. Being a maintainer
entails making sure all tests run and pass on that implementation. When
something breaks on your implementation, you will be responsible for providing
patches in a timely fashion. If critical issues for a particular implementation
exist at the time of a major release, support for that Ruby version may be
dropped.


## Development

After checking out the repo, run `bundle install` to install dependencies.
Then, run `bundle exec rake spec` to run the tests with ruby-rb client.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to [rubygems.org][].


## Contributing

* Fork redis-prescription on GitHub
* Make your changes
* Ensure all tests pass (`bundle exec rake`)
* Send a pull request
* If we like them we'll merge them
* If we've accepted a patch, feel free to ask for commit access!


## Copyright

Copyright (c) 2018 SensorTower Inc.<br>
See [LICENSE.md][] for further details.


[travis.ci]: http://travis-ci.org/sensortower/redis-prescription
[rubygems.org]: https://rubygems.org
[LICENSE.md]: https://github.com/sensortower/redis-prescription/blob/master/LICENSE.txt
