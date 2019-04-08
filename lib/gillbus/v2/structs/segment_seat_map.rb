module Gillbus::V2
  class Structs::SegmentSeatMap < Structs::Base
    field :segment_id, :string
    field :seats, [Structs::Seat], from: "map_seat"

    def floors
      @floors ||= seats.map(&:floor).uniq
    end

    def floor_seats(floor)
      seats.select { |seat| seat.floor == floor }
    end

    # Array of arrays (see result of #format_seats)
    def floor_seat_map(floor)
      floor_seats(floor)
        .group_by(&:row)
        .sort_by(&:first)
        .map do |row, row_seats|
          # TODO: reverse order?
          row_seats.sort_by(&:col)
        end
    end

    def format_seats(floor:, separator: "  ")
      rows =
        floor_seat_map(floor).map do |row_seats|
          row_seats
            .map { |seat| "%3s" % seat.number }
            .join(separator)
        end
      rows.join("\n")
    end
  end
end
