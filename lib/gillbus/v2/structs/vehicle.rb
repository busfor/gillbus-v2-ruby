module Gillbus::V2
  class Structs::Vehicle < Structs::Base
    field :id, :string

    field :model, :string
    field :number, :string

    field :capacity, :integer

    field :vehicle_type, :string
    field :vehicle_class, :string

    field :picture_url, :string
    field :tumbnail_url, :string
  end
end
