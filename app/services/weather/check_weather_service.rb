# frozen_string_literal: true

module Weather
  class CheckWeatherService
    def query_by_position(latitude:, longitude:)
      raise ArgumentError, 'parametter is missing' if latitude.blank? || longitude.blank?

      get_api_or_stored_response(latitude: latitude, longitude: longitude).api_response
    end

    private

    def get_api_or_stored_response(latitude:, longitude:)
      params_hash = { latitude: latitude, longitude: longitude }
      @stored_response = StoredResponse.find_or_initialize_by(
        params_hash: params_hash, api_client: 'Weather::ApiClientService',
        method_name: 'query_by_position'
      )
      unless @stored_response.valid_response
        update_stored_response(latitude: latitude, longitude: longitude)
      end

      @stored_response
    end

    def update_stored_response(latitude:, longitude:)
      @stored_response.api_response = client.query_by_position(latitude: latitude,
                                                               longitude: longitude)
      @stored_response.valid_until = 1.hour.from_now
      @stored_response.save
    end

    def client
      @client ||= Weather::ApiClientService.new
    end
  end
end
