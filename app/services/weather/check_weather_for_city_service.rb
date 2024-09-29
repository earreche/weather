# frozen_string_literal: true

module Weather
  class CheckWeatherForCityService
    def query_weather(city:, country:)
      raise ArgumentError, 'parametter is missing' if city.blank? || country.blank?

      get_api_or_stored_response(city: city, country: country)
      Weather::CheckWeatherService.new.query_by_position(
        latitude: result_latitude, longitude: result_longitude
      )
    end

    private

    def client
      @client ||= Weather::ApiClientService.new
    end

    def get_api_or_stored_response(city:, country:)
      params_hash = { city: city, country: country }
      @stored_response = StoredResponse.find_or_initialize_by(
        params_hash: params_hash, api_client: 'Weather::ApiClientService',
        method_name: 'query_position_for_city'
      )

      return if @stored_response.valid_response

      update_stored_response(city: city, country: country)
    end

    def update_stored_response(city:, country:)
      @stored_response.api_response = client.query_position_for_city(city: city, country: country)
                                            .first
      @stored_response.valid_until = 1.hour.from_now
      @stored_response.save
    end

    def result_latitude
      @stored_response.api_response['lat']
    end

    def result_longitude
      @stored_response.api_response['lon']
    end
  end
end
