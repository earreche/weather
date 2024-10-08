# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Weather::CheckWeatherService do
  let(:latitude_from_uruguay) { -34.901112 }
  let(:longitude_from_uruguay) { -56.164532 }
  let(:latitude) { latitude_from_uruguay }
  let(:longitude) { longitude_from_uruguay }
  let(:params_hash) { { 'latitude' => latitude, 'longitude' => longitude } }
  let(:response) { { 'current' => 'The current weather is super nice' } }
  let(:class_store_time) { described_class::STORE_TIME }

  describe '#query_by_position' do
    subject { described_class.new.query_by_position(latitude: latitude, longitude: longitude) }

    context 'when a parameter is missing' do
      let(:latitude_is_missing) { [true, false].sample }
      let(:latitude) { latitude_is_missing ? [nil, ''].sample : latitude_from_uruguay }
      let(:longitude) { latitude_is_missing ? longitude_from_uruguay : [nil, ''].sample }

      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'when the query was previously cached' do
      let!(:stored_response) do
        create(:stored_response, :weather_query_by_position,
               api_response: response, valid_until: valid_until, params_hash: params_hash)
      end
      let(:valid_until) { 30.minutes.ago }

      context 'when the response is still valid' do
        it 'returns a wrapped response' do
          expect_any_instance_of(Weather::APIClientService).not_to receive(:query_by_position)
          expect(Weather::PayloadWrapper).to receive(:new).with(response).and_call_original

          expect(subject.current).to eq(response['current'])
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
          Timecop.freeze(Time.zone.now)
          allow_any_instance_of(Weather::APIClientService).to receive(:query_by_position).with(
            latitude: latitude, longitude: longitude
          ).and_return(response)
        end

        it 'returns the parsed response' do
          expect_any_instance_of(Weather::APIClientService).to receive(:query_by_position).with(
            latitude: latitude, longitude: longitude
          ).and_return(response)
          expect(Weather::PayloadWrapper).to receive(:new).with(response).and_call_original

          expect(subject.current).to eq(response['current'])
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
          expect(stored_response.api_client).to eq('Weather::APIClientService')
          expect(stored_response.method_name).to eq('query_by_position')
        end
      end
    end

    context 'when the query was not previously stored' do
      before do
        Timecop.freeze(Time.zone.now)
        allow_any_instance_of(Weather::APIClientService).to receive(:query_by_position).with(
          latitude: latitude, longitude: longitude
        ).and_return(response)
      end

      let(:params_hash) { { 'latitude' => latitude, 'longitude' => longitude } }

      it 'returns the parsed response' do
        expect_any_instance_of(Weather::APIClientService).to receive(:query_by_position).with(
          latitude: latitude, longitude: longitude
        ).and_return(response)
        expect(Weather::PayloadWrapper).to receive(:new).with(response).and_call_original

        expect(subject.current).to eq(response['current'])
      end

      it 'creates the stores_response in the db' do
        expect { subject }.to change(StoredResponse, :count).by(1)

        stored_response = StoredResponse.last
        expect(stored_response.params_hash).to eq(params_hash)
        expect(stored_response.api_client).to eq('Weather::APIClientService')
        expect(stored_response.method_name).to eq('query_by_position')
        expect(stored_response.valid_until).to eq(class_store_time.from_now)
      end
    end
  end
end
