# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public' do
  let(:params) { '' }
  let(:latitude) { '-34.901112' }
  let(:longitude) { '-56.164532' }
  let(:api_mocker) { WeatherMocker.new }
  let(:country_code) { 'US' }

  let(:country_option_for_select) { CS.countries.values.sample }
  let(:us_state_option_for_select) { CS.states(country_code).values.sample }

  describe 'GET /' do
    subject do
      get root_path
      response
    end

    context 'when using the City State Gem' do
      before { stub_const 'ENV', ENV.to_h.merge('USE_CITIES_GEM' => 'true') }

      it 'has a select with US states' do
        expect(subject.body).to include(country_option_for_select)
        expect(subject.body).not_to include(us_state_option_for_select)
      end

      it { is_expected.to have_http_status(:ok) }
    end

    context 'when not using the City State Gem' do
      before { stub_const 'ENV', ENV.to_h.merge('USE_CITIES_GEM' => 'false') }

      it 'has a select with countries' do
        expect(subject.body).not_to include(country_option_for_select)
        expect(subject.body).to include(us_state_option_for_select)
      end

      it { is_expected.to have_http_status(:ok) }
    end
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
      let(:params) do
        {
          lat: latitude,
          long: longitude
        }
      end

      before do
        api_mocker.mock_query_by_position_with_success(latitude: latitude, longitude: longitude)
      end

      it 'calls the weather API with correct parameters and returns ok' do
        expect_any_instance_of(Weather::APIClientService).to receive(:query_by_position).with(
          latitude: latitude, longitude: longitude
        ).and_call_original

        expect(subject).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /query_by_city' do
    subject do
      get(query_by_city_path(params), as: :turbo_stream)
      response
    end

    context 'when using the City State Gem' do
      before { stub_const 'ENV', ENV.to_h.merge('USE_CITIES_GEM' => 'true') }

      context 'when both parameters are missing' do
        it { expect { subject }.to raise_error(ArgumentError) }
      end

      context 'when country_code is missing' do
        let(:state) { 'MO' }
        let(:city) { 'Centro' }
        let(:params) do
          {
            city: city,
            state: state
          }
        end

        it { expect { subject }.to raise_error(ArgumentError) }
      end

      context 'when parameters are sent' do
        let(:state) { 'MO' }
        let(:city) { 'Montevideo' }
        let(:country_code) { 'UY' }
        let(:params) do
          {
            city: city,
            state: state,
            country: country_code
          }
        end

        before do
          api_mocker.mock_query_by_position_with_success(latitude: latitude, longitude: longitude)
          api_mocker.mock_query_position_for_city_with_success(
            city: city, state: state, country: country_code
          )
        end

        it 'calls the weather API with correct parameters and returns ok' do
          expect_any_instance_of(Weather::CheckWeatherForCityService)
            .to receive(:query_weather).with(city: city, state: state, country: country_code)
            .and_call_original

          expect(subject).to have_http_status(:ok)
        end
      end
    end

    context 'when not using the City State Gem' do
      before { stub_const 'ENV', ENV.to_h.merge('USE_CITIES_GEM' => 'false') }

      context 'when parameters are sent' do
        let(:state) { 'MO' }
        let(:city) { 'Montevideo' }
        let(:params) do
          {
            city: city,
            state: state
          }
        end

        before do
          api_mocker.mock_query_by_position_with_success(latitude: latitude, longitude: longitude)
          api_mocker.mock_query_position_for_city_with_success(
            city: city, state: state, country: country_code
          )
        end

        it 'calls the weather API with correct parameters and returns ok' do
          expect_any_instance_of(Weather::CheckWeatherForCityService)
            .to receive(:query_weather).with(city: city, state: state, country: nil)
            .and_call_original

          expect(subject).to have_http_status(:ok)
        end
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

    context 'when using the City State Gem' do
      before { stub_const 'ENV', ENV.to_h.merge('USE_CITIES_GEM' => 'true') }

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

        it 'returns a list of US states' do
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

    context 'when not using the City State Gem' do
      before { stub_const 'ENV', ENV.to_h.merge('USE_CITIES_GEM' => 'false') }

      context 'when a country is selected' do
        let(:params) do
          {
            country: country,
            target: 'state'
          }
        end

        let(:response_for_select) { city }

        it 'returns ok status' do
          expect(subject).to have_http_status(:ok)
        end

        it 'does not change the list of US States' do
          expect(subject.body).not_to include(response_for_select)
          expect(subject.body).to include(us_state_option_for_select)
        end
      end

      context 'when a state is selected' do
        let(:params) do
          {
            state: state,
            target: 'city'
          }
        end

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
end
