# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Home Page' do
  let(:home_page) { HomePage.new }
  let(:api_mocker) { WeatherMocker.new }
  let(:latitude) { '-34.901112' }
  let(:longitude) { '-56.164532' }
  let(:current_temperature) { '295.97 F' }
  let(:response_api) { 'The current weather is super nice' }

  feature 'getting the weather for current location' do
    subject { home_page.visit_home_page }

    context 'when the location is not permitted' do
      scenario 'shows text to refreshing the weather after permission is given' do
        subject

        expect(home_page).to have_refresh_text
      end
    end

    context 'when the location is permitted', :js do
      before do
        api_mocker.mock_query_by_position_with_success(latitude: latitude, longitude: longitude)
      end

      scenario 'shows button for refreshing the weather after permission is given' do
        subject

        expect(home_page).to have_weather_at_your_location
        expect(home_page).not_to have_refresh_text
        expect(home_page).to have_current_temperature(current_temperature)
      end
    end
  end

  feature 'getting the weather for a selected city', :js do
    subject { home_page.visit_home_page }

    before do
      api_mocker.mock_query_position_for_city_with_success(city: city, country: country_code)
      api_mocker.mock_query_by_position_with_success(latitude: latitude, longitude: longitude)
    end

    context 'when not using cities_states gem' do
      let(:city) { 'Miami' }
      let(:state) { 'Florida' }
      let(:country_code) { 'US' }

      before { stub_const 'ENV', ENV.to_h.merge('USE_CITIES_GEM' => 'false') }

      scenario 'shows the selected city\'s weather' do
        subject

        click_button 'Change City'

        expect(home_page).not_to have_country_select

        home_page.select_state(state)
        home_page.select_city(city)
        home_page.click_get_weather_for_city

        expect(home_page).to have_weather_at_city(city, country_code)
        expect(home_page).not_to have_weather_at_your_location
        expect(home_page).to have_current_temperature(current_temperature)
      end
    end

    context 'when using cities_states gem' do
      let(:city) { 'Centro' }
      let(:state) { 'Montevideo Department' }
      let(:country) { 'Uruguay' }
      let(:country_code) { 'UY' }

      before { stub_const 'ENV', ENV.to_h.merge('USE_CITIES_GEM' => 'true') }

      scenario 'shows the selected city\'s weather' do
        subject

        home_page.fill_location(country, state, city)
        home_page.click_get_weather_for_city

        expect(home_page).to have_weather_at_city(city, country_code)
        expect(home_page).not_to have_weather_at_your_location
        expect(home_page).to have_current_temperature(current_temperature)
      end
    end
  end
end
