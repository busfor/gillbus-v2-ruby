module Gillbus::V2
  class Structs::AccessToken < Structs::Base
    field :access_token, :string
    field :token_type, :string, default: "Bearer"
    field :expires_in, :integer
    field :expires_on, :date_time_from_timestamp

    def self.from_token_string(token)
      raw_data = { "access_token" => token }
      from_raw_data(raw_data)
    end

    def expired?
      !expires_on.nil? && expires_on <= DateTime.now.new_offset(0)
    end

    def to_s
      access_token
    end

    def auth_header
      "#{token_type} #{access_token}"
    end
  end
end
