# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CacheForApisService do
  let(:api_class) { Weather::ApiClientService }
  let(:method_name) { 'query_by_position' }
  let(:latitude) { -34.901112 }
  let(:longitude) { -56.164532 }
  let(:params_hash) { { latitude: latitude, longitude: longitude } }
  let(:api_response) { { 'current' => 'The current weather is super nice' } }
  let(:class_store_time) { 1.hour }
  let(:payload_wrapper) { nil }

  describe '#call' do
    subject do
      described_class.call(
        api_class: Weather::ApiClientService, method_name: method_name, params_hash: params_hash,
        store_time: class_store_time, payload_wrapper: payload_wrapper
      )
    end

    context 'when the query was previously cached' do
      let!(:stored_response) do
        create(:stored_response, :weather_query_by_position,
               api_response: api_response, valid_until: valid_until, params_hash: params_hash)
      end
      let(:valid_until) { 30.minutes.ago }

      context 'when the response is still valid' do
        context 'when a wrapper is given' do
          let(:payload_wrapper) { Weather::PayloadWrapper }

          it 'returns a wrapped response' do
            expect_any_instance_of(Weather::ApiClientService).not_to receive(:query_by_position)
            expect(Weather::PayloadWrapper).to receive(:new).with(api_response).and_call_original

            expect(subject.current).to eq(api_response['current'])
          end
        end

        it 'returns the parsed response' do
          expect_any_instance_of(Weather::ApiClientService).not_to receive(:query_by_position)

          expect(subject).to eq(api_response)
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
          allow_any_instance_of(Weather::ApiClientService).to receive(:query_by_position).with(
            params_hash
          ).and_return(api_response)
        end

        context 'when a wrapper is given' do
          let(:payload_wrapper) { Weather::PayloadWrapper }

          it 'returns a wrapped response' do
            expect(Weather::PayloadWrapper).to receive(:new).with(api_response).and_call_original

            expect(subject.current).to eq(api_response['current'])
          end

          it 'does not create a new stored_response' do
            expect { subject }.not_to(change(StoredResponse, :count))
          end
        end

        it 'returns the parsed response' do
          expect_any_instance_of(Weather::ApiClientService).to receive(:query_by_position).with(
            params_hash
          ).and_return(api_response)

          expect(subject).to eq(api_response)
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

          expect(stored_response.reload.params_hash).to eq(params_hash.transform_keys(&:to_s))
          expect(stored_response.api_client).to eq('Weather::ApiClientService')
          expect(stored_response.method_name).to eq('query_by_position')
        end
      end
    end

    context 'when the query was not previously stored' do
      before do
        Timecop.freeze(Time.zone.now)
        allow_any_instance_of(Weather::ApiClientService).to receive(:query_by_position).with(
          params_hash
        ).and_return(api_response)
      end

      context 'when a wrapper is given' do
        let(:payload_wrapper) { Weather::PayloadWrapper }

        it 'returns a wrapped response' do
          expect(Weather::PayloadWrapper).to receive(:new).with(api_response).and_call_original

          expect(subject.current).to eq(api_response['current'])
        end

        it 'creates the stores_response in the db' do
          expect { subject }.to change(StoredResponse, :count).by(1)

          stored_response = StoredResponse.last
          expect(stored_response.params_hash).to eq(params_hash.transform_keys(&:to_s))
          expect(stored_response.api_client).to eq('Weather::ApiClientService')
          expect(stored_response.method_name).to eq('query_by_position')
          expect(stored_response.valid_until).to eq(class_store_time.from_now)
        end
      end

      it 'creates the stores_response in the db' do
        expect { subject }.to change(StoredResponse, :count).by(1)

        stored_response = StoredResponse.last
        expect(stored_response.params_hash).to eq(params_hash.transform_keys(&:to_s))
        expect(stored_response.api_client).to eq('Weather::ApiClientService')
        expect(stored_response.method_name).to eq('query_by_position')
        expect(stored_response.valid_until).to eq(class_store_time.from_now)
      end

      it 'returns the parsed response' do
        expect(subject).to eq(api_response)
      end
    end
  end
end
