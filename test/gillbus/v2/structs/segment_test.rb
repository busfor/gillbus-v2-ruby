require "test_helper"

describe Gillbus::V2::Structs::Segment do
  let(:search_response) do
    JSON.parse(File.read("test/fixtures/responses/search_trips.json"))
  end
  let(:segment_data) { search_response.dig("segments", 0) }
  let(:segment) { Gillbus::V2::Structs::Segment.from_raw_data(segment_data) }

  it "returns correct fields" do
    assert_equal "QlNGdGVzdGFnZW50fjEyOTB-MTYxMX4xOzh-fjB-RjY4MUE0Q0NCRUFBRjA4RDBDNjEzMzQ5NkJBMTRGRTU", segment.id
    assert_equal "B4FBDC4A1A7F2DFDE040A8C063035416", segment.carrier_id
    assert_equal "QkFaLUEwNzkuMjM=", segment.vehicle_id
    assert_equal "0", segment.resource_id

    assert_equal "13:15", segment.travel_time

    assert_equal "MD_TEST - 10707/003Д Киев - Львов", segment.trip_number
    assert_nil segment.trip_name
    assert_equal "internal", segment.trip_type

    assert_equal "919319", segment.departure_point_id
    assert_equal "1136893", segment.arrival_point_id

    assert_equal DateTime.new(2019, 4, 5, 21, 0, 0), segment.departure_date_time
    assert_equal DateTime.new(2019, 4, 6, 10, 15, 0), segment.arrival_date_time

    assert_equal "2", segment.departure_platform

    assert_equal true, segment.reservation_enabled
    assert_equal 40 * 60, segment.reservation_lifetime

    assert_nil segment.stop_reservation_time

    assert_equal true, segment.has_transfer

    assert_equal true, segment.can_discount

    assert_equal true, segment.voluntary_return_enabled

    assert_equal true, segment.sale_enabled
    assert_equal "", segment.redirect_url
  end

  describe "price" do
    let(:price) { segment.price }

    it "returns correct total and netto" do
      assert_equal Money.new(83361, "RUB"), price.total
      assert_equal Money.new(0, "RUB"), price.netto
    end

    describe "tariffs" do
      let(:tariffs) { price.tariffs }
      let(:tariff) { tariffs.first }

      it "returns array of tariffs" do
        assert_equal 1, tariffs.size
      end

      it "returns correct fields for tariff" do
        assert_nil tariff.id
        assert_equal "YPROM", tariff.code

        assert_equal Money.new(83361, "RUB"), tariff.cost

        assert_nil tariff.seat_class

        assert_equal Date.new(2019, 2, 9), tariff.start_date
        assert_equal Date.new(2019, 4, 15), tariff.end_date

        assert_equal "Акционный тариф", tariff.name
        assert_equal "Акционный тариф стоимости проезда одного пассажира в прямом направлении.\nВ стоимость билета включена стоимость перевозки багажа состоящего из 3 (троих) чемоданов (до 30кг. размер 100x50x30 см.) и сумка - ручная кладь до 5 кг. Дополнительный багаж перевозится при наличии свободного места в багажном отделении автобуса.\nСтоимость перевозки дополнительного места багажа составляет 10% от стоимости билета.", tariff.description
        assert_equal "15", tariff.notes
      end

      describe "refund_conditions" do
        let(:refund_conditions) { tariff.refund_conditions }
        let(:refund_condition) { refund_conditions.first }

        it "returns array" do
          assert_equal 3, refund_conditions.size
        end

        it "returns correct fields" do
          assert_nil refund_condition.time_from
          assert_equal 24 * 60 * 60, refund_condition.time_till

          assert_equal 87.0, refund_condition.return_percent
          assert_equal Money.new(72524, "RUB"), refund_condition.return_amount

          assert_equal "Добровольно, не менее 24 часов до отправления автобуса Возвращается 100% стоимости тарифа. Ориентировочная сумма возврата 725.24", refund_condition.description
        end
      end
    end
  end

  describe "options" do
    it "returns nil" do
      # TODO: добавить данные и покрыть тестами
      assert_nil segment.options
    end
  end

  describe "route" do
    let(:route_point) { segment.route.first }

    it "returns array of points" do
      assert_equal 13, segment.route.size
    end

    it "returns correct fields for point" do
      assert_equal "919319", route_point.point_id
      assert_nil route_point.vehicle_id

      assert_equal "2", route_point.departure_platform

      assert_equal DateTime.new(2019, 4, 5, 21, 0, 0), route_point.departure_date_time
      # invalid format: "2019-04-05 "
      assert_nil route_point.arrival_date_time

      assert_equal false, route_point.check_point
      assert_equal false, route_point.transfer_point

      assert_equal 0, route_point.distance_from_start
    end
  end
end
