# frozen_string_literal: true

module Weather
  class CheckWeatherForCityService
    def query_weather(city:, country:)
      raise ArgumentError, 'parametter is missing' if city.blank? || country.blank?

      result = client.query_position_for_city(city: city, country: country).first

      Weather::CheckWeatherService.new.query_by_position(
        latitude: result['lat'], longitude: result['lon']
      )
    end

    private

    def client
      @client ||= Weather::ApiClientService.new
    end
  end
end
