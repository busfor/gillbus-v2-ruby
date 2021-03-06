module Gillbus::V2
  class Structs::RefundConditions < Structs::Base
    field :time_from, :integer
    field :time_till, :integer

    field :return_percent, :float
    field :return_amount, Money,
      from: { amount: "return_amount", currency: "currency" }

    field :description, :string, from: "condition_description"
  end
end
