module Gillbus::V2
  class Structs::Segment < Structs::Base
    field :id, :string
    field :carrier_id, :string
    field :vehicle_id, :string
    field :resource_id, :string

    field :price, Structs::SegmentPrice

    field :travel_time, :string

    field :trip_number, :string, from: "number"
    field :trip_name, :string, from: "name"
    field :trip_type, Enum.("international", "internal")

    field :departure_point_id, :string
    field :arrival_point_id, :string

    field :departure_date_time, :date_time_hh_mm, from: "departureDateTime"
    field :arrival_date_time, :date_time_hh_mm, from: "arrivalDateTime"

    field :departure_platform, :string, from: "platform"

    field :reservation_enabled, :boolean, from: "reservation_enable"
    field :reservation_lifetime, :time_interval_from_minutes

    # время до отправления рейса, после которого запрещено бронирование
    field :stop_reservation_time, :time_interval_from_minutes

    # наличие пересадки (смены автобуса)
    field :has_transfer, :boolean, from: "has_hub"

    # стоимость может измениться при продаже в случае автоматического применения льготных тарифов
    field :can_discount, :boolean

    # возможность добровольного возврата
    field :voluntary_return_enabled, :boolean, from: "return_enable"

    # Если sale_enabled == false, то необходим редирект на redirect_url
    # (на этот рейс возможна продажа только на сайте владельца)
    field :sale_enabled, :boolean, from: "sale_enable"
    field :redirect_url, :string

    field :options, Structs::SegmentOptions

    field :route, [Structs::RoutePoint]
  end
end
