# frozen_string_literal: true

FactoryBot.define do
  factory :stored_response, class: StoredResponse do
    params_hash { { lat: 1, lon: 1 } }
    api_response { { response: 'valid' } }

    trait :weather_query_by_position do
      valid_until { 1.hour.from_now }
      api_client { 'Weather::APIClientService' }
      method_name { 'query_by_position' }
    end

    trait :weather_query_for_city do
      valid_until { 1.day.from_now }
      api_client { 'Weather::APIClientService' }
      method_name { 'query_position_for_city' }
    end
  end
end
