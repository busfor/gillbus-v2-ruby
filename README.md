# Gillbus::V2

[![Build Status](https://travis-ci.com/busfor/gillbus-v2-ruby.svg?branch=master)](https://travis-ci.com/busfor/gillbus-v2-ruby)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gillbus-v2'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gillbus-v2

## Usage

### Authentication

When the access-token is not existed you should use methods `authenticate` or `authenticate!`. Method `authenticate!` raises exception if authentication is failed.

```ruby
client = Gillbus::V2::Client.new(base_url: 'https://example.com')
client.authenticate!(
  username: 'test',
  password: '12345',
  lang: 'ru',
  time_zone: 'Europe/Moscow',
)
```

After `authenticate` you need to check the result with `authenticated?`.

```ruby
client.authenticate(
  username: 'test',
  password: '12345',
  lang: 'ru',
  time_zone: 'Europe/Moscow',
)
client.authenticated?
# => true | false
```

After successfull authentication you need to save an access_token.

```ruby
# only token
token_string = client.access_token.to_s

# full token data (token type, expiration time)
token_data = client.access_token.raw_data
```

When you have an access_token you should be able to pass it to the client.

```ruby
client = Gillbus::V2::Client.new(
  base_url: 'https://example.com',
  access_token: token_string, # or token_data
)
```

You need to check the expiration time of the token. If the token becomes expired you should repeat the authentication process again.

```ruby
if client.access_token.expired?
  client.authenticate!(...)
  new_token = client.access_token.raw_data
  # store new token
end
```

The method `expired?` returns `false` when there is no info about the token’s expiration time.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/busfor/gillbus-v2-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Gillbus::V2 project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/busfor/gillbus-v2-ruby/blob/master/CODE_OF_CONDUCT.md).
