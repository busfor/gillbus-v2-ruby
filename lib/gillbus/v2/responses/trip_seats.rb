module Gillbus::V2
  module Responses
    class TripSeats < Base
      def seat_maps
        @seat_maps ||=
          (json_body["maps_seat"] || []).map do |item|
            Structs::SegmentSeatMap.from_raw_data(item)
          end
      end
    end
  end
end
