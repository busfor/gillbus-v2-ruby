module Gillbus::V2
  class Structs::Pagination < Structs::Base
    field :uuid, :string, from: "page_uuid"
    field :pages_count, :integer, from: "page_count"
    field :current_page, :integer, from: "page_number"
    field :expires_on, :date_time_rfc3339, from: "expires_in"

    def next_page
      current_page + 1 if current_page < pages_count
    end

    def expired?
      !expires_on.nil? && expires_on <= DateTime.now.new_offset(0)
    end
  end
end
