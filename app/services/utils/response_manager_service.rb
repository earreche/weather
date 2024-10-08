# frozen_string_literal: true

module Utils
  class ResponseManagerService
    attr_reader :response, :messages_klass

    def initialize(messages_klass)
      @messages_klass = messages_klass
      @response = { status: '', result: {} }
    end

    def abort(msg_key, errors, status = :bad_request)
      set_status(status, msg_key)
      error(errors)
      response
    end

    def success(msg_key)
      set_status('ok', msg_key)
      response
    end

    def error(errors)
      response.merge!({ errors: errors })
    end

    def add(params)
      response[:result].merge!(params)
    end

    def set_status(new_status, msg_key)
      response[:status] = new_status.to_sym
      response[:status_response] = status_message(msg_key)
    end

    def status_message(msg_key)
      messages_klass::MESSAGES[msg_key]
    end
  end
end
