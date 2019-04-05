module Gillbus::V2
  class Structs::RoutePoint < Structs::Base
    field :point_id, :string
    field :vehicle_id, :string

    field :departure_platform, :string, from: "platform"

    field :departure_date_time, :date_time_hh_mm, from: "departureDateTime"
    field :arrival_date_time, :date_time_hh_mm, from: "arrivalDateTime"

    field :check_point, :boolean
    field :transfer_point, :boolean, from: "is_hub"

    field :distance_from_start, :integer, from: "distance"
  end
end
