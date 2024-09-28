# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Home Page' do
  let(:home_page) { HomePage.new }
  let(:api_mocker) { WeatherMocker.new }
  let(:latitude) { '-34.901112' }
  let(:longitude) { '-56.164532' }

  feature 'getting the weather for current location' do
    subject { home_page.visit_home_page }

    context 'when the location is not permitted' do
      it 'shows button for refreshing the weather after permission is given' do
        subject

        expect(home_page).to have_refresh_button
      end
    end

    context 'when the location is permitted', :js do
      let(:response_api) { 'The current weather is super nice' }

      before do
        api_mocker.mock_query_by_position_with_success(latitude: latitude, longitude: longitude)
      end

      it 'shows button for refreshing the weather after permission is given' do
        subject

        expect(home_page).to have_weather(response_api)
        expect(home_page).not_to have_refresh_button
      end
    end
  end
end
