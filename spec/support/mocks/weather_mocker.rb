# frozen_string_literal: true

require 'rails_helper'

class WeatherMocker
  include RSpec::Mocks::ExampleMethods
  BASE_API_URL = 'https://api.openweathermap.org/data/3.0/onecall/'
  WEATHER_API_ACCESS_TOKEN = 'WEATHER_API_ACCESS_TOKEN'

  def mock_query_by_position_with_success(latittude:, longitude:)
    response_body = <<~JSON
      {
        "lat": #{latittude},
        "lon": #{longitude},
        "tz": "-03:00",
        "date": "2024-09-26",
        "units": "standard",
        "weather_overview": "The current weather is super nice"
      }
    JSON

    WebMock
      .stub_request(:get, "#{BASE_API_URL}overview?lat=#{latittude}&lon=#{longitude}&#{app_id}")
      .with(body: '', headers: default_api_request_headers)
      .to_return(status: 200, body: response_body, headers: default_response_headers)
  end

  def app_id
    "appid=#{WEATHER_API_ACCESS_TOKEN}"
  end

  def mock_query_by_position_with_lat_out_of_range(latittude:, longitude:)
    response_body = <<~JSON
      {
        "code": "400",
        "message": "The valid range of latitude in degrees is -90 and +90",
        "parameters": [
          "lat"
        ]
      }
    JSON

    WebMock
      .stub_request(:get, "#{BASE_API_URL}overview?lat=#{latittude}&lon=#{longitude}&#{app_id}")
      .with(body: '', headers: default_api_request_headers)
      .to_return(status: 400, body: response_body, headers: default_response_headers)
  end

  def default_api_request_headers(extra_params = {})
    {
      'Accept' => '*/*',
      'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type' => 'application/json',
      'User-Agent' => 'Ruby'
    }.merge(extra_params)
  end

  def default_response_headers(extra_params = {})
    {
      'Content-Type' => 'application/json'
    }.merge(extra_params)
  end
end
