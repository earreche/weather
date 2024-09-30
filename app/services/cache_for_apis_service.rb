# frozen_string_literal: true

class CacheForApisService
  def self.call(args)
    new(**args).api_or_stored_response
  end

  def initialize(api_class:, method_name:, params_hash:, store_time:, payload_wrapper: nil)
    @api_class = api_class
    @method_name = method_name
    @params_hash = params_hash
    @store_time = store_time
    @payload_wrapper = payload_wrapper
  end

  def api_or_stored_response
    @stored_response = StoredResponse.find_or_initialize_by(
      params_hash: params_hash.transform_keys(&:to_s),
      api_client: api_class.to_s, method_name: method_name
    )
    update_stored_response unless @stored_response.valid_response?(store_time.ago)

    wrap_if_needed(@stored_response.api_response)
  end

  private

  attr_reader :api_class, :method_name, :params_hash, :store_time, :payload_wrapper

  def update_stored_response
    @stored_response.api_response = api_class.new.send(method_name, **params_hash)
    @stored_response.valid_until = store_time.from_now
    @stored_response.save
  end

  def wrap_if_needed(api_response)
    return payload_wrapper.new(api_response) if payload_wrapper

    api_response
  end
end
