require "test_helper"

describe "Authentication" do
  let(:base_url) { "https://example.com" }
  let(:client) { Gillbus::V2::Client.new(base_url: base_url) }

  let(:token_string) { token_data["access_token"] }
  let(:token_data) do
    {
      "access_token" => "5EBE2294ECD0E0F08EAB7690D2A6EE69",
      "token_type" => "Bearer",
      "expires_in" => 86400,
      "expires_on" => 1553767061,
    }
  end

  before do
    Timecop.freeze(DateTime.parse("2019-03-27 13:00 +03"))
  end

  after do
    Timecop.return
  end

  it "is not authenticated by default" do
    assert_nil client.access_token
    assert_equal false, client.authenticated?
  end

  describe "Client#authenticate" do
    it "authenticates and saves access_token" do
      VCR.use_cassette("authentication_success") do
        client.authenticate(
          username: 'test',
          password: '12345',
          lang: 'ru',
          time_zone: 'Europe/Moscow',
        )
      end

      assert_equal true, client.authenticated?

      assert_equal token_string, client.access_token.to_s
      assert_equal token_data, client.access_token.raw_data
    end

    it "returns api response if authentication is failed" do
      response = VCR.use_cassette("authentication_failure") do
        client.authenticate(
          username: 'test',
          password: '12345',
          lang: 'ru',
          time_zone: 'Europe/Moscow',
        )
      end

      assert_equal false, client.authenticated?
      assert_nil client.access_token

      assert_equal false, response.success?
      assert_equal 403, response.error_code
      assert_equal "User not found", response.error_message
    end
  end

  describe "Client#authenticate!" do
    it "authenticates and saves access_token" do
      VCR.use_cassette("authentication_success") do
        client.authenticate!(
          username: 'test',
          password: '12345',
          lang: 'ru',
          time_zone: 'Europe/Moscow',
        )
      end

      assert_equal true, client.authenticated?

      assert_equal token_string, client.access_token.to_s
      assert_equal token_data, client.access_token.raw_data
    end

    it "raises exception if authentication is failed" do
      VCR.use_cassette("authentication_failure") do
        exception = assert_raises(Gillbus::V2::AuthenticationFailed) do
          client.authenticate!(
            username: 'test',
            password: '12345',
            lang: 'ru',
            time_zone: 'Europe/Moscow',
          )
        end
        assert_equal "User not found", exception.message
      end

      assert_equal false, client.authenticated?
      assert_nil client.access_token
    end
  end

  describe "with access_token" do
    it "authenticates by token string" do
      client = Gillbus::V2::Client.new(
        base_url: base_url,
        access_token: token_string,
      )

      assert_equal true, client.authenticated?
      assert_equal token_string, client.access_token.to_s
    end

    it "authenticates by full token data" do
      client = Gillbus::V2::Client.new(
        base_url: base_url,
        access_token: token_data,
      )

      assert_equal true, client.authenticated?

      assert_equal token_string, client.access_token.to_s
      assert_equal token_data, client.access_token.raw_data
    end
  end
end
