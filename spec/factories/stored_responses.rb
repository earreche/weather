# frozen_string_literal: true

FactoryBot.define do
  factory :stored_response, class: StoredResponse do
    params_hash { { lat: 1, lon: 1 } }
    valid_until { 1.hour.from_now }
    api_response { {} }

    trait :weather_query_by_position do
      api_client { 'Weather::ApiClientService' }
      method_name { 'query_by_position' }
    end

    trait :weather_query_for_city do
      api_client { 'Weather::ApiClientService' }
      method_name { 'query_position_for_city' }
    end
  end
end
