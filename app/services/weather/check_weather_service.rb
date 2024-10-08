# frozen_string_literal: true

module Weather
  class CheckWeatherService
    STORE_TIME = 1.hour.freeze

    def query_by_position(latitude:, longitude:)
      raise ArgumentError, 'parametter is missing' if latitude.blank? || longitude.blank?

      api_or_stored_response({ latitude: latitude, longitude: longitude })
    end

    private

    def api_or_stored_response(params_hash)
      CacheForApisService.call(api_class: Weather::APIClientService,
                               payload_wrapper: Weather::PayloadWrapper,
                               method_name: 'query_by_position',
                               params_hash: params_hash,
                               store_time: STORE_TIME)
    end
  end
end
