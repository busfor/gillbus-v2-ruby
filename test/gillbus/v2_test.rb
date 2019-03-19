require "test_helper"

class Gillbus::V2Test < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Gillbus::V2::VERSION
  end
end
