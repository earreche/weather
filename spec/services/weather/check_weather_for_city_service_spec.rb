# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Weather::CheckWeatherForCityService do
  let(:latitude_from_uruguay) { -34.901112 }
  let(:longitude_from_uruguay) { -56.164532 }
  let(:latitude) { latitude_from_uruguay }
  let(:longitude) { longitude_from_uruguay }
  let(:response) { [{ 'lat' => latitude, 'lon' => longitude }] }

  describe '#query_weather' do
    subject { described_class.new.query_weather(city: city, country: country) }

    context 'when a parameter is missing' do
      let(:city_is_missing) { [true, false].sample }
      let(:city) { city_is_missing ? [nil, ''].sample : 'Montevideo' }
      let(:country) { city_is_missing ? 'Uruguay' : [nil, ''].sample }

      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'when sending correct parameters' do
      let(:city) { 'Montevideo' }
      let(:country) { 'Uruguay' }

      before do
        allow_any_instance_of(Weather::ApiClientService).to receive(:query_position_for_city).with(
          city: city, country: country
        ).and_return(response)
      end

      it 'stores the expected value in the cache' do
        expect_any_instance_of(Weather::CheckWeatherService).to receive(:query_by_position).with(
          latitude: response.first['lat'], longitude: response.first['lon']
        )

        subject
      end
    end
  end
end
