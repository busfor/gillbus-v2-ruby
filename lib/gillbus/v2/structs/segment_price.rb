module Gillbus::V2
  class Structs::SegmentPrice < Structs::Base
    field :total, Money, from: { amount: "total", currency: "currency" }
    field :netto, Money, from: { amount: "netto", currency: "currency" }

    field :tariffs, [Structs::SegmentTariff], enrich_with: %w[currency]
  end
end
