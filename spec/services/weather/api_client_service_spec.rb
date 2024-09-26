# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Weather::ApiClientService do
  let(:api_mocker) { WeatherMocker.new }
  let(:latittude_from_uruguay) { -34.901112 }
  let(:longitude_from_uruguay) { -56.164532 }
  let(:latittude) { latittude_from_uruguay }
  let(:longitude) { longitude_from_uruguay }
  let(:response_overview) { 'The current weather is super nice' }

  describe '#query_by_position' do
    subject { described_class.new.query_by_position(latittude: latittude, longitude: longitude) }

    context 'when a parameter is missing' do
      let(:latittude_is_missing) { [true, false].sample }
      let(:latittude) { latittude_is_missing ? [nil, ''].sample : latittude_from_uruguay }
      let(:longitude) { latittude_is_missing ? longitude_from_uruguay : [nil, ''].sample }

      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'when a valid place is given' do
      before do
        api_mocker.mock_query_by_position_with_success(latittude: latittude, longitude: longitude)
      end

      it 'returns the parsed response' do
        expect(subject['weather_overview']).to eq(response_overview)
      end
    end

    context 'when an invalid place is given' do
      let(:latittude) { 999 }
      let(:error_message) do
        "Could not retrieve weather for [latittude: #{latittude}, longitude #{longitude}}]. " \
          'Details: The valid range of latitude in degrees is -90 and +90 for the southern and ' \
          'northern hemisphere, respectively. Check parameter/s: lat'
      end

      before do
        api_mocker.mock_query_by_position_with_lat_out_of_range(
          latittude: latittude, longitude: longitude
        )
      end

      it { expect { subject }.to raise_error(Weather::Error, error_message) }
    end
  end
end
