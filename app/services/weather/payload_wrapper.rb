# frozen_string_literal: true

module Weather
  class PayloadWrapper
    def initialize(payload)
      @payload = payload
    end

    def current
      payload['current']
    end

    def hourly
      payload['hourly']
    end

    def daily
      payload['daily']
    end

    def current_weather
      dig_weather(current).first
    end

    def hourly_weather
      dig_weather(hourly)
    end

    def daily_weather
      dig_weather(daily)
    end

    private

    attr_reader :payload

    def dig_weather(partial_payload)
      partial_payload['weather']
    end
  end
end
