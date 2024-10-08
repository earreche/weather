# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Weather::CheckWeatherForCityService do
  let(:latitude_from_uruguay) { -34.901112 }
  let(:longitude_from_uruguay) { -56.164532 }
  let(:class_store_time) { described_class::STORE_TIME }
  let(:latitude) { latitude_from_uruguay }
  let(:longitude) { longitude_from_uruguay }
  let(:response) { [{ 'lat' => latitude, 'lon' => longitude }] }
  let(:response_weather) { { 'current' => 'The current weather is super nice' } }
  let(:wrapped_response) { Weather::PayloadWrapper.new(response_weather) }
  let(:city) { 'Centro' }
  let(:state) { 'MO' }
  let(:country) { 'Uruguay' }
  let(:country_code) { 'UY' }

  describe '#query_weather' do
    subject { described_class.new.query_weather(city: city, state: state, country: country_code) }

    context 'when city is missing' do
      let(:city) { nil }

      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'when country is missing' do
      let(:country_code) { nil }

      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'when state is missing' do
      let(:state) { nil }

      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'when sending correct parameters' do
      before do
        Timecop.freeze(Time.zone.now)
        allow_any_instance_of(Weather::CheckWeatherService)
          .to receive(:query_by_position).and_return(wrapped_response)
      end

      context 'when the query was previously cached' do
        let!(:stored_response) do
          create(:stored_response, :weather_query_for_city,
                 api_response: response, valid_until: valid_until, params_hash: params_hash)
        end
        let(:params_hash) { { 'city' => city, 'state' => state, 'country' => country_code } }
        let(:valid_until) { 30.minutes.ago }

        context 'when the response is still valid' do
          it 'returns the parsed response' do
            expect_any_instance_of(Weather::APIClientService)
              .not_to receive(:query_position_for_city)

            expect(subject).to eq(wrapped_response)
          end

          it 'does not create a new stored_response' do
            expect { subject }.not_to(change(StoredResponse, :count))
          end

          it 'does not update the stored_response valid_until time' do
            expect { subject }.not_to(change { stored_response.reload.valid_until })
          end
        end

        context 'when the response is no longer valid' do
          let(:valid_until) { class_store_time.ago - 1.hour }

          before do
            allow_any_instance_of(Weather::ApiClientService).to receive(:query_position_for_city)
              .with(city: city, state: state, country: country_code).and_return(response)
          end

          it 'does not create a new stored_response' do
            expect { subject }.not_to(change(StoredResponse, :count))
          end

          it 'updates the stored_response valid_until time' do
            expect { subject }.to change { stored_response.reload.valid_until }
              .from(valid_until).to(class_store_time.from_now)
          end

          it 'keeps the stored_response attributes' do
            subject

            expect(stored_response.reload.params_hash).to eq(params_hash)
            expect(stored_response.api_client).to eq('Weather::ApiClientService')
            expect(stored_response.method_name).to eq('query_position_for_city')
          end

          it 'returns the parsed response' do
            expect_any_instance_of(Weather::APIClientService).to receive(:query_position_for_city)

            expect(subject).to eq(wrapped_response)
          end
        end
      end

      context 'when the query was not previously stored' do
        let(:params_hash) { { 'city' => city, 'state' => state, 'country' => country_code } }

        before do
          Timecop.freeze(Time.zone.now)
          allow_any_instance_of(Weather::ApiClientService).to receive(:query_position_for_city)
            .with(city: city, state: state, country: country_code).and_return(response)
        end

        it 'returns the parsed response' do
          expect_any_instance_of(Weather::APIClientService).to receive(:query_position_for_city)

          expect(subject).to eq(wrapped_response)
        end

        it 'calls the weather service with the correct parameters' do
          expect_any_instance_of(Weather::CheckWeatherService).to receive(:query_by_position).with(
            latitude: response.first['lat'], longitude: response.first['lon']
          )

          subject
        end

        it 'creates the stores_response in the db' do
          expect { subject }.to change(StoredResponse, :count).by(1)

          stored_response = StoredResponse.last
          expect(stored_response.params_hash).to eq(params_hash)
          expect(stored_response.api_client).to eq('Weather::ApiClientService')
          expect(stored_response.method_name).to eq('query_position_for_city')
          expect(stored_response.valid_until).to eq(class_store_time.from_now)
        end
      end
    end
  end
end
