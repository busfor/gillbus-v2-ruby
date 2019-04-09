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

### Fetch locations

For fetch the first page you should use method `get_locations`, other pages - `get_locations_page`. For example:

```ruby
response = client.get_locations(
  langs: %w[en ru uk pl],
  limit_for_page: 100,
)
# first 100 locations
response.locations

while response.pagination.next_page
  response = client.get_locations_page(
    pagination_uuid: response.pagination.uuid,
    page_number: response.pagination.next_page,
  )
  # other locations by 100 records
  response.locations
end
```

Every response should contain the following data:

```ruby
# list of locations
response.locations

# dictionaries
response.location_types
response.location_sub_types
response.location_additional_fields

# usage of dictionaries
location = response.locations.first
location_type =
  response.location_types.detect do |item|
    item.id == location.type_id
  end
location_sub_type =
  response.location_sub_types.detect do |item|
    item.id == location.sub_type_id
  end
location.additional_fields.each do |field_id, field_value|
  field =
    response.location_additional_fields.detect do |item|
      item.id == field_id
    end
  field_name = field.name
end
```

Also you can load changes from a certain point of time instead of loading of the whole list. In order to do this you should pass param`from_datetime` to `get_locations`. Only the changed locations will be included in the response.

```ruby
# get changes for last hour
response = client.get_locations(
  langs: %w[en ru uk pl],
  limit_for_page: 10,
  from_datetime: DateTime.now - 3600,
)

while response.pagination.next_page
  # ...
end
```

Each location contains fields:

- `modified_at` - last modification time
- `deleted` - if true then location has been removed

### Search trips

Search of trips works in the same way as `get_locations`:

- `search_trips` for first page
- `search_trips_page` for other

```ruby
response = client.search_trips(
  from_id: 111,
  to_id: 222,
  date: Date.today + 1,
  back_date: Date.today + 5,
  passengers_count: 1,
  limit_for_page: 20,
)
response.trips

while response.pagination.next_page
  response = client.search_trips_page(
    pagination_uuid: response.pagination.uuid,
    page_number: response.pagination.next_page,
  )
  response.trips
end
```

Every response contains trips and dictionaries for them:

```ruby
response.trips

# dictionaries
response.carriers
response.vehicles
response.points
```

### Get trip seats

Example of usage:

```ruby
response = client.get_trip_seats(
  trip_id: "123",
  date: Date.today + 1,
  back_date: Date.today + 5,
  passengers_count: 1,
)

response.seat_maps.each do |seat_map|
  # Array of all seats
  seat_map.seats

  # Seats by floor
  seat_map.floors.each do |floor|
    # Array of floor seats
    seat_map.floor_seats(floor)
    # Array of arrays of seats
    seat_map.floor_seat_map(floor)
    # Print the same result
    puts seat_map.format_seats(floor: floor)
  end
end
```

See `Structs::SegmentSeatMap` for details.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Test scripts

You can make requests with the following scripts:

```bash
bin/test_auth
bin/test_locations
bin/test_search
```

In order to use them you need to setup ENV vars:

```bash
cp .env.sample .env
# Fill .env with correct data
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/busfor/gillbus-v2-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Gillbus::V2 project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/busfor/gillbus-v2-ruby/blob/master/CODE_OF_CONDUCT.md).
