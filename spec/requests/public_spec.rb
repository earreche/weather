# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public' do
  let(:params) { '' }
  let(:latitude) { '-34.901112' }
  let(:longitude) { '-56.164532' }

  describe 'GET /' do
    subject do
      get root_path
      response
    end

    it { is_expected.to have_http_status(:ok) }
  end

  describe 'GET /query_by_position' do
    subject do
      get(query_by_position_path(params), as: :turbo_stream)
      response
    end

    context 'when a parameter is missing' do
      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'when parameters are sent' do
      let(:api_response) { { weather_overview: 'The current weather is super nice' } }
      let(:params) do
        {
          lat: latitude,
          long: longitude
        }
      end

      it 'calls the weather API with correct parameters and returns ok' do
        expect_any_instance_of(Weather::ApiClientService).to receive(:query_by_position).with(
          latitude: latitude, longitude: longitude
        ).and_return(api_response)

        expect(subject).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /query_by_city' do
    subject do
      get(query_by_city_path(params), as: :turbo_stream)
      response
    end

    context 'when a parameter is missing' do
      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'when parameters are sent' do
      let(:city) { 'Montevideo' }
      let(:country) { 'Uruguay' }
      let(:api_response) { { weather_overview: 'The current weather is super nice' } }
      let(:params) do
        {
          city: city,
          country: country
        }
      end

      it 'calls the weather API with correct parameters and returns ok' do
        expect_any_instance_of(Weather::CheckWeatherForCityService).to receive(:query_weather).with(
          city: city, country: country
        ).and_return(api_response)

        expect(subject).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /filter_select_location', :js do
    subject do
      get(filter_select_location_path(params), as: :turbo_stream)
      response
    end

    let(:state) { 'MO' }
    let(:city) { 'Centro' }
    let(:country) { 'UY' }

    context 'when a country is selected' do
      let(:params) do
        {
          country: country,
          target: 'state'
        }
      end
      let(:response_for_select) { CS.states(country).values.sample }

      it 'returns ok status' do
        expect(subject).to have_http_status(:ok)
      end

      it 'returns a list of states' do
        expect(subject.body).to include(response_for_select)
      end
    end

    context 'when a state is selected' do
      let(:params) do
        {
          state: state,
          target: 'city'
        }
      end
      let!(:states) { CS.states(country) }
      let(:response_for_select) { CS.cities(state).sample }

      it 'returns ok status' do
        expect(subject).to have_http_status(:ok)
      end

      it 'returns a list of cities' do
        expect(subject.body).to include(response_for_select)
      end
    end

    context 'when nothing is selected' do
      let(:params) do
        {}
      end

      it { expect { subject }.to raise_error(ArgumentError) }
    end
  end
end
