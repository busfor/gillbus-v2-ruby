module Gillbus::V2
  module Responses
    class Authenticate < Responses::Base
      def success?
        http_status == 200 && !access_token.nil?
      end

      def access_token
        if json_body["access_token"]
          Structs::AccessToken.from_raw_data(json_body)
        end
      end
    end
  end
end
