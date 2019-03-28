$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "gillbus/v2"
require "timecop"
require "vcr"
require "pry"

VCR.configure do |config|
  config.cassette_library_dir = "test/fixtures/vcr_cassettes"
  config.hook_into :faraday
  config.before_record do |item|
    item.response.body.force_encoding('UTF-8')
  end
  # https://github.com/vcr/vcr/blob/master/features/request_matching/README.md
  config.default_cassette_options[:match_requests_on] = [
    :method,
    :uri,
    :headers,
    :body,
  ]
end

require "minitest/autorun"
