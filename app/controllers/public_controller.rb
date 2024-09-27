# frozen_string_literal: true

class PublicController < ApplicationController

  def index
  end

  def query_by_position
    @weather = check_weather_service.dig('weather_overview')
  end
  
  private
  
  def permitted_params
    params.permit(:lat,:long)
  end

  def check_weather_service
    Weather::CheckWeatherService.new.query_by_position(
      latittude: permitted_params[:lat],
      longitude: permitted_params[:long],
    )
  end
end
