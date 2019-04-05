module Gillbus::V2
  class Structs::SegmentTariff < Structs::Base
    field :id, :string
    field :code, :string

    field :cost, Money, from: { amount: "cost", currency: "currency" }

    field :seat_class, :string, from: "class"

    field :start_date, :date
    field :end_date, :date

    field :name, :string
    field :description, :string, from: "description_tariff"
    field :notes, :string, from: "note"

    field :refund_conditions, [Structs::RefundConditions],
      enrich_with: %w[currency]
  end
end
