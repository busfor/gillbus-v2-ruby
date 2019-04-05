module Gillbus::V2
  class Structs::Point < Structs::Base
    field :id, :string
    field :parent_id, :string

    field :name, :string
    field :address, :string
  end
end
