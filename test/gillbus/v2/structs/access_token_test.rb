require "test_helper"

describe Gillbus::V2::Structs::AccessToken do
  before do
    @raw_data = {
      "access_token" => "qwerty",
      "token_type" => "Bearer",
      "expires_in" => 86400,
      "expires_on" => 1553351378,
    }
    @access_token = Gillbus::V2::Structs::AccessToken.from_raw_data(@raw_data)
  end

  it "creates from raw_data" do
    assert_equal @raw_data, @access_token.raw_data

    assert_equal "qwerty", @access_token.access_token
    assert_equal "Bearer", @access_token.token_type
    assert_equal 86400, @access_token.expires_in
    assert_equal DateTime.parse("2019-03-23T14:29:38+00:00"), @access_token.expires_on
  end

  it "creates from token string" do
    @access_token =
      Gillbus::V2::Structs::AccessToken.from_token_string("qwerty")

    assert_equal "qwerty", @access_token.access_token
    assert_equal "Bearer", @access_token.token_type
    assert_nil @access_token.expires_in
    assert_nil @access_token.expires_on
  end

  describe "#expired?" do
    it "returns false without expires_on" do
      @raw_data.delete("expires_on")
      token = Gillbus::V2::Structs::AccessToken.from_raw_data(@raw_data)

      assert_equal false, token.expired?
    end

    it "returns false when expires_on < current time" do
      Timecop.freeze(@access_token.expires_on - 1) do
        assert_equal false, @access_token.expired?
      end
    end

    it "returns true when expires_on = current time" do
      Timecop.freeze(@access_token.expires_on) do
        assert_equal true, @access_token.expired?
      end
    end

    it "returns true when expires_on > current time" do
      Timecop.freeze(@access_token.expires_on + 1) do
        assert_equal true, @access_token.expired?
      end
    end
  end

  describe "#to_s" do
    it "returns token string" do
      assert_equal "qwerty", @access_token.to_s
    end
  end
end
