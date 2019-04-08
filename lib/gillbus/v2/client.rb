module Gillbus::V2
  class Client
    attr_reader :base_url
    attr_reader :access_token

    def initialize(base_url:, access_token: nil)
      @base_url = base_url
      @access_token =
        if access_token.is_a?(Structs::AccessToken)
          access_token
        elsif access_token.is_a?(String)
          Structs::AccessToken.from_token_string(access_token)
        elsif access_token.is_a?(Hash)
          Structs::AccessToken.from_raw_data(access_token)
        end
    end

    def authenticated?
      !access_token.nil? && !access_token.expired?
    end

    def authenticate(username:, password:, lang:, time_zone:)
      params = {
        username: username,
        password: password,
        lang: lang,
        timeZone: time_zone,
      }
      response = call_api(:post, "/v2/login", params,
        auth_required: false,
        response_class: Responses::Authenticate,
      )
      @access_token = response.access_token
      response
    end

    def authenticate!(**args)
      response = authenticate(**args)
      unless authenticated?
        raise AuthenticationFailed, response.error_message
      end
    end

    def get_locations(langs: %w[en], limit_for_page: 50, from_datetime: nil)
      params = {
        lang_array: langs,
        limit: limit_for_page,
        timestamp: from_datetime&.rfc3339,
      }
      call_api(:get, "/geo/v2/locations", params,
        response_class: Responses::Locations,
      )
    end

    def get_locations_page(pagination_uuid:, page_number:)
      params = {
        page_uuid: pagination_uuid,
        number_page: page_number,
      }
      call_api(:get, "/geo/v2/locations/page", params,
        response_class: Responses::Locations,
      )
    end

    # search_mode:
    # - full - искать все рейсы (по умолчанию)
    # - direct - искать только прямые рейсы
    def search_trips(from_id:, to_id:, date:, back_date: nil, passengers_count: 1, search_mode: "full", limit_for_page: 20)
      params = {
        from_id: from_id,
        to_id: to_id,
        date: date.iso8601,
        back_date: back_date&.iso8601,
        pass_count: passengers_count,
        search_mode: search_mode,
        limit: limit_for_page,
      }
      call_api(:get, "/search/v2/trips", params,
        response_class: Responses::SearchTrips,
      )
    end

    def search_trips_page(pagination_uuid:, page_number:)
      params = {
        page_uuid: pagination_uuid,
        number_page: page_number,
      }
      call_api(:get, "/search/v2/trips/page", params,
        response_class: Responses::SearchTrips,
      )
    end

    def get_trip_seats(trip_id:, date:, back_date: nil, passengers_count: 1)
      params = {
        date: date,
        back_date: back_date,
        pass_count: passengers_count,
      }
      call_api(:get, "/search/v2/trips/#{trip_id}/seats", params,
        response_class: Responses::TripSeats,
      )
    end

    private

    def call_api(http_method, url, params, auth_required: true, response_class: Responses::Base)
      raise AuthenticationRequired if auth_required && !authenticated?

      params.reject! { |k, v| v.nil? }

      http_response =
        begin
          connection.public_send(http_method) do |request|
            request.url url
            params.each do |key, value|
              request.params[key.to_s] = value
            end
            request.headers['accept'] = 'application/json'
            if auth_required
              request.headers['Authorization'] = access_token.auth_header
            end
          end
        rescue Faraday::Error => e
          raise e
        end

      response_class.new(http_response)
    end

    def connection
      @connection ||= Faraday.new(url: base_url) do |faraday|
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
        faraday.options[:params_encoder] = Faraday::FlatParamsEncoder
      end
    end
  end
end
