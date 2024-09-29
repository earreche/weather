# frozen_string_literal: true

FactoryBot.define do
  factory :stored_response, class: StoredResponse do
    params_hash { { lat: 1, lon: 1 } }
    api_client { 'Weather::ApiClientService' }
    method_name { 'query_by_position' }
    valid_until { 1.hour.from_now }
    api_response { {} }
  end
end
