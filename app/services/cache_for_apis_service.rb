# frozen_string_literal: true

class CacheForApisService
  def self.call(args)
    new(**args).api_or_stored_response
  end

  def initialize(api_class:, method_name:, params_hash:, store_time:)
    @api_class = api_class
    @method_name = method_name
    @params_hash = params_hash
    @store_time = store_time
  end

  def api_or_stored_response
    @stored_response = StoredResponse.find_or_initialize_by(
      params_hash: params_hash.transform_keys(&:to_s),
      api_client: api_class.to_s, method_name: method_name
    )
    update_stored_response unless @stored_response.valid_response?(store_time.ago)

    @stored_response.api_response
  end

  private

  attr_reader :api_class, :method_name, :params_hash, :store_time

  def update_stored_response
    @stored_response.api_response = api_class.new.send(method_name, **params_hash)
    @stored_response.valid_until = store_time.from_now
    @stored_response.save
  end
end
