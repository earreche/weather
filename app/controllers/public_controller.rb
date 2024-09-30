# frozen_string_literal: true

class PublicController < ApplicationController
  def index; end

  def query_by_position
    render turbo_stream: turbo_stream.replace(
      'current-weather', partial: 'weather', locals: {
        weather: Weather::WeatherPresenter.new(check_weather_service),
        id: 'current-response',
        location: 'your location'
      }
    )
  end

  def query_by_city
    render turbo_stream: turbo_stream.replace(
      'current-weather', partial: 'weather', locals: {
        weather: Weather::WeatherPresenter.new(check_weather_service_for_city),
        id: 'current-response',
        location: "#{params[:city]}, #{params[:country]}"
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
    params.permit(:country, :state, :target)
  end

  def options_for_select
    if permitted_params_for_location[:country].present?
      CS.states(permitted_params_for_location[:country]).invert
    elsif permitted_params_for_location[:state].present?
      CS.cities(permitted_params_for_location[:state])
    end
  end

  def check_weather_service
    Weather::CheckWeatherService.new.query_by_position(
      latitude: permitted_params_for_weather[:lat], longitude: permitted_params_for_weather[:long]
    )
  end

  def check_weather_service_for_city
    Weather::CheckWeatherForCityService.new.query_weather(
      city: params[:city], country: params[:country]
    )
  end
end
