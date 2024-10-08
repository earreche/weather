# frozen_string_literal: true

module API
  class ApplicationController < ActionController::API
    def response_service
      @response_service ||= Utils::ResponseManagerService.new(messages_klass)
    end

    def messages_klass
      Utils::BaseMessages
    end

    private

    def error_response(msg_key, errors, status = :bad_request)
      response = response_service.abort(msg_key, [errors], status)

      render json: response, status: response[:status]
    end
  end
end
