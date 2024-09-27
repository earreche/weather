# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Weather::CheckWeatherService do
  let(:latittude_from_uruguay) { -34.901112 }
  let(:longitude_from_uruguay) { -56.164532 }
  let(:latittude) { latittude_from_uruguay }
  let(:longitude) { longitude_from_uruguay }
  let(:cache_name) { "#{latittude}, #{longitude}" }
  let(:response) { { weather_overview: 'The current weather is super nice' } }

  describe '#query_by_position' do
    subject { described_class.new.query_by_position(latittude: latittude, longitude: longitude) }

    context 'when a parameter is missing' do
      let(:latittude_is_missing) { [true, false].sample }
      let(:latittude) { latittude_is_missing ? [nil, ''].sample : latittude_from_uruguay }
      let(:longitude) { latittude_is_missing ? longitude_from_uruguay : [nil, ''].sample }

      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'when the query was previously cached' do
      before do
        Rails.cache.clear
        Rails.cache.write(cache_name, response, { expires_in: 1.hour })
      end

      it 'returns the parsed response' do
        expect_any_instance_of(Weather::ApiClientService).not_to receive(:query_by_position)

        expect(subject).to eq(response)
      end
    end

    context 'when the query was not previously cached' do
      before do
        Rails.cache.clear
        allow_any_instance_of(Weather::ApiClientService).to receive(:query_by_position).with(
          latittude: latittude, longitude: longitude
        ).and_return(response)
        allow(Rails.cache).to receive(:write)
      end

      it 'stores the expected value in the cache' do
        subject

        expect(Rails.cache).to have_received(:write).with(
          cache_name, response, { expires_in: 1.hour }
        )
      end
    end
  end
end
