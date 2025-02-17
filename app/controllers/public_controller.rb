# frozen_string_literal: true

class PublicController < ApplicationController
  def index
    @use_cities_gem = ENV['USE_CITIES_GEM'] == 'true'
    @states = CountriesValue.new.states
  end

  def query_by_position
    render turbo_stream: turbo_stream.replace(
      'current-weather', partial: 'weather', locals: {
        weather: Weather::WeatherPresenter.new(check_weather_service),
        location: 'your location'
      }
    )
  end

  def query_by_city
    render turbo_stream: turbo_stream.replace(
      'current-weather', partial: 'weather', locals: {
        weather: Weather::WeatherPresenter.new(check_weather_service_for_city),
        location: "#{city}, #{state} - #{country || 'US'}"
      }
    )
  end

  def filter_select_location
    @options = options_for_select
    @target = permitted_params_for_location[:target]

    raise ArgumentError, 'parametter is missing' unless @options && @target
  end

  private

  def permitted_params_for_weather
    params.permit(:lat, :long)
  end

  def permitted_params_for_location
    params.permit(:country, :state, :city, :target)
  end

  def options_for_select
    if permitted_params_for_location[:country].present?
      CountriesValue.new(permitted_params_for_location[:country]).states
    elsif permitted_params_for_location[:state].present?
      StatesValue.new(permitted_params_for_location[:state]).cities
    end
  end

  def check_weather_service
    Weather::CheckWeatherService.new.query_by_position(
      latitude: permitted_params_for_weather[:lat], longitude: permitted_params_for_weather[:long]
    )
  end

  def check_weather_service_for_city
    Weather::CheckWeatherForCityService.new.query_weather(
      city: city, state: state, country: country
    )
  end

  def city
    @city ||= permitted_params_for_location[:city]
  end

  def state
    @state ||= permitted_params_for_location[:state]
  end

  def country
    @country ||= permitted_params_for_location[:country]
  end
end
