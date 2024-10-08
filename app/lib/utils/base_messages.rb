# frozen_string_literal: true

module Utils
  module BaseMessages
    SUCCESS = :success
    ERROR = :error
    NOT_FOUND = :not_found
    BAD_PARAMS = :bad_params

    MESSAGES = {
      success: 'Request processed successfully',
      error: 'Could not save the record',
      not_found: 'Could not find a record with that id',
      bad_params: 'One or more required params are missing'
    }.freeze

    ERROR_MESSAGES = {
      bad_params: { message: 'Please check your request params' }
    }.freeze
  end
end
