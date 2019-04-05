module Gillbus::V2
  module Responses
    class SearchTrips < Responses::Base
      def trips
        @trips ||= (json_body["trips"] || []).map do |item|
          trip_data = item.dup
          trip_data["direct_trip"].map! { |id| segment_data(id) }
          trip_data["back_trip"].map! { |id| segment_data(id) }
          Structs::Trip.from_raw_data(trip_data)
        end
      end

      def carriers
        @carriers ||= (json_body["carriers"] || []).map do |item|
          Structs::Carrier.from_raw_data(item)
        end
      end

      def vehicles
        @vehicles ||= (json_body["vehicles"] || []).map do |item|
          Structs::Vehicle.from_raw_data(item)
        end
      end

      def points
        @points ||= (json_body["points"] || []).map do |item|
          Structs::Point.from_raw_data(item)
        end
      end

      def pagination
        @pagination ||=
          if json_body["pages_info"]
            Structs::Pagination.from_raw_data(json_body["pages_info"])
          end
      end

      private

      def segment_data(segment_id)
        @segments_data_by_ids ||=
          (json_body["segments"] || []).group_by { |item| item["id"] }
        @segments_data_by_ids[segment_id]&.first
      end
    end
  end
end
