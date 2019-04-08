module Gillbus::V2
  class Structs::Trip < Structs::Base
    field :id, :string, from: "trip_id"
    field :direct_segments, [Structs::Segment], from: "direct_trip"
    field :back_segments, [Structs::Segment], from: "back_trip"
  end
end
