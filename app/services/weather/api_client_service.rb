# frozen_string_literal: true

module Weather
  class Error < StandardError; end

  class ApiClientService
    include HTTParty

    base_uri ENV.fetch('WEATHER_API_BASE')

    headers 'Content-Type' => 'application/json'

    # Check weather for a location.
    #
    # @param lat [Integer] is the Latittude.
    # @param lon [Integer] is the Longitude
    # @return the parsed response of the API.

    def query_by_position(latittude:, longitude:)
      raise ArgumentError, 'parametter is missing' if latittude.blank? || longitude.blank?

      response = execute_request('get', "/overview?#{query_params_position(latittude, longitude)}")
      unless success_response?(response)
        error_detail = fetch_error_message(response.parsed_response)
        raise Error, error_message(latittude, longitude, error_detail)
      end

      response.parsed_response
    end

    private

    attr_reader :api_key

    def query_params_position(latittude, longitude)
      "lat=#{latittude}&lon=#{longitude}&appid=#{api_access_token}"
    end

    def api_access_token
      @api_access_token ||= ENV.fetch('WEATHER_API_ACCESS_TOKEN')
    end

    def execute_request(method, url, body = nil)
      options = { body: body&.to_json }.compact

      self.class.send(method, url, options)
    end

    def success_response?(response)
      response.code == 200
    end

    def fetch_error_message(error_response)
      "#{error_response['message']}. Check parameter/s: " \
        "#{error_response['parameters']&.join(',')}"
    end

    def error_message(latittude, longitude, error_detail)
      "Could not retrieve weather for [latittude: #{latittude}, longitude #{longitude}}]. " \
        "Details: #{error_detail}"
    end
  end
end
