module Gillbus::V2
  class Structs::Pagination < Structs::Base
    field :uuid, :string, from: "page_uuid"
    field :pages_count, :integer, from: "page_count"
    field :current_page, :integer, from: "page_number"
    field :expires_in, :integer

    def next_page
      current_page + 1 if current_page < pages_count
    end
  end
end
