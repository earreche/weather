# frozen_string_literal: true

class StoredResponse < ApplicationRecord
  validates :api_client,
            :method_name,
            :params_hash,
            :api_response,
            :valid_until, presence: true

  def valid_response?(valid_until_date)
    persisted? && valid_until > valid_until_date
  end
end
