module Gillbus::V2
  # TODO: use in seatmap response or remove
  class Structs::Seat < Structs::Base
    field :id, :string
    field :number, :string

    field :floor, :integer
    field :col, :integer
    field :row, :integer

    field :seat_class, :string, from: "class"

    field :status, Enum.(
      "EMPTY",
      "ORDERED",
      "BLOCKED",
      "FREE",
      "BOOKED",
      "SALED",
      "SPESIAL",
      "REGISTERED",
      "TECHNICAL",
      "PRIORITY",
    )
  end
end
