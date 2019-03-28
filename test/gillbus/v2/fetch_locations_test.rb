require "test_helper"

describe "Fetch locations" do
  let(:base_url) { "https://example.com" }
  let(:access_token) { "5EBE2294ECD0E0F08EAB7690D2A6EE69" }

  let(:client) do
    Gillbus::V2::Client.new(base_url: base_url, access_token: access_token)
  end

  let(:pagination_uuid) { "3d02e87c-3f53-4a57-8a9f-e2fda0f9c809" }

  def get_locations(from_datetime: nil)
    vcr_name = "get_locations"
    vcr_name += "_from_#{from_datetime.iso8601}" if from_datetime
    VCR.use_cassette(vcr_name) do
      client.get_locations(
        langs: %w[en ru uk pl],
        limit_for_page: 100,
        from_datetime: from_datetime,
      )
    end
  end

  def get_locations_page(page_number:)
    VCR.use_cassette("get_locations_page_#{page_number}") do
      client.get_locations_page(
        pagination_uuid: pagination_uuid,
        page_number: page_number,
      )
    end
  end

  def get_locations_error
    VCR.use_cassette("get_locations_error") do
      client.get_locations(
        langs: %w[qw er ty],
        limit_for_page: 100,
      )
    end
  end

  describe "fetch first page" do
    let(:response) { get_locations }

    it "returns locations" do
      assert_equal true, response.success?
      assert_equal 100, response.locations.size
    end

    it "returns dictionaries" do
      assert_equal true, response.success?
      assert_equal 1, response.location_types.size
      assert_equal 1, response.location_types.size
      assert_equal 5, response.location_additional_fields.size
    end

    it "returns pagination info" do
      assert_equal true, response.success?
      assert_equal pagination_uuid, response.pagination.uuid
      assert_equal 1999, response.pagination.pages_count
      assert_equal 1, response.pagination.current_page
      assert_equal 2, response.pagination.next_page
    end
  end

  describe "fetch second page" do
    let(:response) { get_locations_page(page_number: 2) }

    it "returns locations" do
      assert_equal true, response.success?
      assert_equal 100, response.locations.size
    end

    it "returns dictionaries" do
      assert_equal true, response.success?
      assert_equal 1, response.location_types.size
      assert_equal 1, response.location_types.size
      assert_equal 5, response.location_additional_fields.size
    end

    it "returns pagination info" do
      assert_equal true, response.success?
      assert_equal pagination_uuid, response.pagination.uuid
      assert_equal 1999, response.pagination.pages_count
      assert_equal 2, response.pagination.current_page
      assert_equal 3, response.pagination.next_page
    end
  end

  describe "fetch last page" do
    let(:response) { get_locations_page(page_number: 1999) }

    it "returns locations" do
      assert_equal true, response.success?
      assert_equal 84, response.locations.size
    end

    it "returns dictionaries" do
      assert_equal true, response.success?
      assert_equal 1, response.location_types.size
      assert_equal 1, response.location_types.size
      assert_equal 5, response.location_additional_fields.size
    end

    it "returns pagination info" do
      assert_equal true, response.success?
      assert_equal pagination_uuid, response.pagination.uuid
      assert_equal 1999, response.pagination.pages_count
      assert_equal 1999, response.pagination.current_page
      assert_nil response.pagination.next_page
    end
  end

  describe "fetch changes from a certain point in time" do
    let(:date_time_now) { DateTime.parse("2019-03-28 13:45 +03") }
    let(:response) do
      Timecop.freeze(date_time_now) do
        get_locations(from_datetime: DateTime.now - 60)
      end
    end

    it "returns locations" do
      assert_equal true, response.success?
      assert_equal 4, response.locations.size
    end
  end

  describe "errors" do
    let(:response) { get_locations_error }

    it "returns error code and message" do
      assert_equal false, response.success?
      assert_equal 400, response.error_code
      assert_equal "Unsupported locale values[qw;er]", response.error_message
    end

    it "returns blank locations and dictionaries" do
      assert_equal 0, response.locations.size
      assert_equal 0, response.location_types.size
      assert_equal 0, response.location_types.size
      assert_equal 0, response.location_additional_fields.size
    end

    it "returns blank pagination" do
      assert_nil response.pagination
    end
  end
end
