module Gillbus::V2
  class Structs::Seat < Structs::Base
    field :id, :string
    field :number, :string, from: "num"

    field :seat_type, :string # TODO: Enum
    field :status, :string # TODO: Enum

    # ярус
    field :floor, :integer, from: "z"
    # номер ряда, сверху вниз
    field :row, :integer, from: "x"
    # номер места в ряду, слева направо
    field :col, :integer, from: "y"
  end
end
