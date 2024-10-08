# frozen_string_literal: true

module Weather
  class ForCityQueryService

    def initialize(response_service, city, state, country)
      @response_service = response_service
      @city = city
      @state = state
      @country = country
    end
    
    def call
      check_weather
      response_service.response
    rescue ArgumentError => e
      abort_response(e.message)
    end

    private

    attr_reader :city, :state, :country, :response_service

    def abort_response(error_message)
      response_service.abort(:bad_params, error_message, :unprocessable_entity)

      response_service.response
    end

    def wrapped_api_query
      ::Weather::CheckWeatherForCityService
        .new.query_weather(city: city, state: state, country: country)
    end

    def check_weather
      response_service.success(:success)
      response_service.add(wrapped_api_query.current)
    end
  end
end
