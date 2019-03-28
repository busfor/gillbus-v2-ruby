module Gillbus::V2
  module Responses
    class Base
      attr_reader :http_status
      attr_reader :http_headers
      attr_reader :http_body

      def initialize(http_response)
        @http_status = http_response.status
        @http_headers = http_response.headers
        @http_body = http_response.body
      end

      def json_body
        return @json_body if defined?(@json_body)
        @json_body = JSON.parse(@http_body) rescue {}
      end

      def success?
        http_status == 200
      end

      def error_code
        json_body["status"] unless success?
      end

      def error_message
        json_body["message"] unless success?
      end
    end
  end
end
