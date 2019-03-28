$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "gillbus/v2"
require "timecop"
require "vcr"
require "pry"

VCR.configure do |config|
  config.cassette_library_dir = "test/vcr_cassettes"
  config.hook_into :faraday
  config.before_record do |item|
    item.response.body.force_encoding('UTF-8')
  end
end

require "minitest/autorun"
