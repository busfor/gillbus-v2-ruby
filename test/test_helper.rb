$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "gillbus/v2"
require "timecop"
require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "test/vcr_cassettes"
  config.hook_into :faraday
end

require "minitest/autorun"
