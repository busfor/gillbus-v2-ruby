module Gillbus::V2
  class Structs::LocationAdditionalField < Structs::Base
    field :id, :integer
    field :name, :translations_hash
  end
end
