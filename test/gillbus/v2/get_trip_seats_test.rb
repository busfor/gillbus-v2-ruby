require "test_helper"

describe "Get trip seats" do
  let(:base_url) { "https://example.com" }
  let(:access_token) { "5EBE2294ECD0E0F08EAB7690D2A6EE69" }

  let(:client) do
    Gillbus::V2::Client.new(base_url: base_url, access_token: access_token)
  end

  let(:form_id) { 1611 }
  let(:to_id) { 235900 }
  let(:date) { Date.new(2019, 04, 10) }
  let(:passengers_count) { 1 }

  def search_trips
    client.search_trips(
      from_id: form_id,
      to_id: to_id,
      date: date,
      passengers_count: passengers_count,
    )
  end

  def get_trip_seats(trip_id:)
    client.get_trip_seats(
      trip_id: trip_id,
      date: date,
      passengers_count: passengers_count,
    )
  end

  describe "Success response" do
    let(:response) do
      VCR.use_cassette("search_trips_and_get_trip_seats") do
        trip = search_trips.trips.first
        get_trip_seats(trip_id: trip.id)
      end
    end

    it "returns seats for segments" do
      assert_equal true, response.success?

      segment_id = "QlNGdGVzdGFnZW50fjE2MTF-MjM1OTAwfjE7OH5-MH41OTI2NjU5NDQ2ODkwRTFCREE5QTVEODZFN0QzRDI5Nw"

      assert_equal [segment_id], response.seat_maps.map(&:segment_id)
      assert_equal [70], response.seat_maps.map(&:seats).map(&:size)
    end

    describe "segment seat_map" do
      let(:seat_map) { response.seat_maps.first }

      it "returns array of floors and seats for each" do
        assert_equal [0], seat_map.floors
        assert_equal 70, seat_map.floor_seats(0).size
      end

      it "returned formatted seat_map for floor" do
        expected = <<~TEXT
           В1                  ВД
           4С   3С        2С   1С
           8С   7С        6С   5С
          12С  11С       10С   9С
          16С  15С       14С  13С
          20С  19С       18С  17С
           В2            22С  21С
                         24С  23С
          28С  27С       26С  25С
          32С  31С       30С  29С
          36С  35С       34С  33С
          40С  39С       38С  37С
          44С  43С       42С  41С
          49С  48С  47С  46С  45С
        TEXT

        assert_equal expected.rstrip, seat_map.format_seats(floor: 0)
      end
    end
  end

  describe "error response" do
    let(:response) do
      VCR.use_cassette("get_trip_seats_error") do
        get_trip_seats(trip_id: "invalid")
      end
    end

    it "returns empty results" do
      assert_equal false, response.success?
      assert_equal "Invalid trip ID", response.error_message

      assert_equal [], response.seat_maps
    end
  end
end
