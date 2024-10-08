# frozen_string_literal: true

require 'rails_helper'

class WeatherMocker
  include RSpec::Mocks::ExampleMethods
  BASE_API_URL = 'https://api.openweathermap.org/'
  WEATHER_API_ACCESS_TOKEN = 'WEATHER_API_ACCESS_TOKEN'

  def mock_query_by_position_with_success(latitude:, longitude:)
    response_body = <<~JSON
      {
        "lat": #{latitude},
        "lon": #{longitude},
        "tz": "-03:00",
        "date": "2024-09-26",
        "units": "standard",
        "current": {
          "temp": 295.97,
          "feels_like": 295.98,
          "pressure": 1010,
          "humidity": 64,
          "dew_point": 288.81,
          "weather": [
            {
              "id": 803,
              "main": "Clouds",
              "description": "broken clouds",
              "icon": "04d"
            }
          ]
        },
        "hourly": [
          {
            "dt": 1727640000,
            "temp": 295.97,
            "feels_like": 295.98,
            "weather": [
                {
                  "id": 803,
                  "main": "Clouds",
                  "description": "broken clouds",
                  "icon": "04d"
                }
            ]
          },
          {
            "dt": 1727643600,
            "temp": 294.9,
            "feels_like": 294.91,
            "weather": [
              {
                "id": 803,
                "main": "Clouds",
                "description": "broken clouds",
                "icon": "04d"
              }
            ]
          }
        ],
         "daily": [
          {
            "dt": 1727622000,
            "temp": {
              "min": 287.68,
              "max": 295.97
            },
            "weather": [
              {
                "id": 804,
                "main": "Clouds",
                "description": "overcast clouds",
                "icon": "04d"
              }
            ]
          }
        ]
      }
    JSON

    WebMock
      .stub_request(:get, "#{BASE_API_URL}data/3.0/onecall?" \
                          "lat=#{latitude}&lon=#{longitude}&units=imperial&#{app_id}")
      .with(body: '', headers: default_api_request_headers)
      .to_return(status: 200, body: response_body, headers: default_response_headers)
  end

  def mock_query_by_position_with_lat_out_of_range(latitude:, longitude:)
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
      .stub_request(:get, "#{BASE_API_URL}data/3.0/onecall?" \
                          "lat=#{latitude}&lon=#{longitude}&units=imperial&#{app_id}")
      .with(body: '', headers: default_api_request_headers)
      .to_return(status: 400, body: response_body, headers: default_response_headers)
  end

  def mock_query_position_for_city_with_success(city:, state:, country:)
    response_body = <<~JSON
      [{
        "city": "#{city}",
        "state": "#{state}",
        "country": "#{country}",
        "lat": -34.901112,
        "lon": -56.164532
      }]
    JSON

    WebMock
      .stub_request(
        :get, "#{BASE_API_URL}geo/1.0/direct?q=#{city},#{state},#{country}&limit=1&#{app_id}"
      )
      .with(body: '', headers: default_api_request_headers)
      .to_return(status: 200, body: response_body, headers: default_response_headers)
  end

  def mock_query_position_for_city_with_no_result(city:, state:, country:)
    response_body = <<~JSON
      []
    JSON

    WebMock
      .stub_request(
        :get, "#{BASE_API_URL}geo/1.0/direct?q=#{city},#{state},#{country}&limit=1&#{app_id}"
      )
      .with(body: '', headers: default_api_request_headers)
      .to_return(status: 200, body: response_body, headers: default_response_headers)
  end

  private

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

  def app_id
    "appid=#{WEATHER_API_ACCESS_TOKEN}"
  end
end
