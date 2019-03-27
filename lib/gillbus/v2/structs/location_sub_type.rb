module Gillbus::V2
  class Structs::LocationSubType < Structs::Base
    field :id, :integer
    field :name, :translations_hash
    field :short_name, :translations_hash
  end
end
