# frozen_string_literal: true

module Weather
  class CheckWeatherForCityService
    STORE_TIME = 1.day.freeze

    def query_weather(city:, state:, country:)
      country = CountriesValue.new(country).country
      raise ArgumentError, 'parametter is missing' if city.blank? || state.blank? || country.blank?

      @api_response = api_or_stored_response({ city: city, state: state, country: country }).first
      Weather::CheckWeatherService.new.query_by_position(
        latitude: result_latitude, longitude: result_longitude
      )
    end

    private

    def api_or_stored_response(params_hash)
      CacheForApisService.call(api_class: Weather::ApiClientService,
                               method_name: 'query_position_for_city',
                               params_hash: params_hash,
                               store_time: STORE_TIME)
    end

    def result_latitude
      @api_response['lat']
    end

    def result_longitude
      @api_response['lon']
    end
  end
end
