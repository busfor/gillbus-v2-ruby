require "test_helper"

describe "Search trips" do
  let(:base_url) { "https://example.com" }
  let(:access_token) { "5EBE2294ECD0E0F08EAB7690D2A6EE69" }

  let(:client) do
    Gillbus::V2::Client.new(base_url: base_url, access_token: access_token)
  end

  let(:from_id) { 1290 }
  let(:to_id) { 1611 }
  let(:pagination_uuid) { "4B95320D2F080BF93A76B7542248C42A" }

  before do
    Timecop.freeze(DateTime.parse("2019-04-03 14:00 +03"))
  end

  after do
    Timecop.return
  end

  def search_trips
    client.search_trips(
      from_id: from_id,
      to_id: to_id,
      date: Date.parse("2019-04-05"),
      passengers_count: 1,
      limit_for_page: 20,
    )
  end

  def search_trips_page(page_number:)
    client.search_trips_page(
      pagination_uuid: pagination_uuid,
      page_number: page_number,
    )
  end

  describe "get first page" do
    let(:response) do
      VCR.use_cassette("search_trips") do
        search_trips
      end
    end

    it "returns pagination" do
      assert_equal true, response.success?
      assert_equal pagination_uuid, response.pagination.uuid
      assert_equal 1, response.pagination.pages_count
      assert_equal 1, response.pagination.current_page
      assert_nil response.pagination.next_page
    end

    it "returns trips" do
      assert_equal true, response.success?
      assert_equal 2, response.trips.size
    end

    it "returns dictionaries" do
      assert_equal true, response.success?
      assert_equal 1, response.carriers.size
      assert_equal 1, response.vehicles.size
      assert_equal 13, response.points.size
    end
  end

  describe "get specific page" do
    let(:response) do
      VCR.use_cassette("search_trips_page_1") do
        search_trips_page(page_number: 1)
      end
    end

    it "returns pagination" do
      assert_equal true, response.success?
      assert_equal pagination_uuid, response.pagination.uuid
      assert_equal 1, response.pagination.pages_count
      assert_equal 1, response.pagination.current_page
      assert_nil response.pagination.next_page
    end

    it "returns trips" do
      assert_equal true, response.success?
      assert_equal 2, response.trips.size
    end

    it "returns dictionaries" do
      assert_equal true, response.success?
      assert_equal 1, response.carriers.size
      assert_equal 1, response.vehicles.size
      assert_equal 13, response.points.size
    end
  end

  describe "errors" do
    let(:response) do
      VCR.use_cassette("search_trips_error") do
        search_trips
      end
    end

    it "returns error info" do
      assert_equal false, response.success?
      assert_equal 500, response.error_code
      assert_equal "No message available", response.error_message
    end

    it "returns blank pagination, trips and dictionaries" do
      assert_equal false, response.success?
      assert_nil response.pagination
      assert_equal [], response.trips
      assert_equal [], response.carriers
      assert_equal [], response.vehicles
      assert_equal [], response.points
    end
  end
end
