# frozen_string_literal: true

module Weather
  class CheckWeatherService
    def query_by_position(latittude:, longitude:)
      raise ArgumentError, 'parametter is missing' if latittude.blank? || longitude.blank?

      cache_name = "#{latittude}, #{longitude}"
      redis_value = Rails.cache.fetch(cache_name)
      return redis_value if redis_value.present?

      redis_value = client.query_by_position(latittude: latittude, longitude: longitude)
      Rails.cache.write(cache_name, redis_value, expires_in: 1.hour)
    end

    private

    def client
      @client ||= Weather::ApiClientService.new
    end
  end
end
