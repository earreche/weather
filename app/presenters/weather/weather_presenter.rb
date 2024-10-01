# frozen_string_literal: true

module Weather
  class WeatherPresenter
    def initialize(payload)
      @payload = payload
    end

    def current_weather_details
      current.slice('humidity', 'pressure', 'dew_point')
    end

    def current_temperature
      "#{current['temp']} #{degree_unit}"
    end

    def current_feels_like
      "#{current['feels_like']} #{degree_unit}"
    end

    def current_description
      current_weather['description']
    end

    def current_ico
      present_image(current_weather['icon'])
    end

    def group_presenter(initial_filter:, amount: 5, drop: 1, divide_by: '1.hour')
      duration, time_text = divide_by.split('.')
      gap = duration.to_i.send(time_text)
      initial_filter.drop(drop).first(amount).map do |next_weather|
        gap_time = calculate_gap_time(next_weather['dt'], gap)
        {
          description: next_weather.dig('weather', 0, 'description').capitalize,
          icon: present_image(next_weather.dig('weather', 0, 'icon')),
          time: "In #{gap_time} #{time_text.capitalize.pluralize(gap_time)}"
        }.merge(present_temperatures(next_weather))
      end
    end

    private

    delegate_missing_to :payload
    attr_reader :payload

    def present_temperatures(weather)
      unless weather['temp'].try(:include?, 'min')
        return { temp: "#{weather['temp']} #{degree_unit}" }
      end

      {
        min: "#{weather.dig('temp', 'min')} #{degree_unit}",
        max: "#{weather.dig('temp', 'max')} #{degree_unit}"
      }
    end

    def degree_unit
      'F'
    end

    def calculate_gap_time(time, gap)
      ((Time.zone.at(time) - Time.zone.now) / gap).round
    end

    def present_image(image_name)
      "weather_icons/#{image_name}.png"
    end
  end
end
