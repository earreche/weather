# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatesValue do
  describe '.cities' do
    subject { described_class.new(state_code).cities }

    let(:cities_for_select) { CS.cities(state_code, country_code) }
    let(:state_code) { CS.states(country_code).keys.sample }
    let(:country_code) { CS.countries.keys.sample }

    context 'when not using state_cities gem' do
      let(:us_country_code) { 'US' }
      let(:state_code) { CS.states(us_country_code).keys.sample }
      let(:us_cities_for_select) { CS.cities(state_code, us_country_code) }

      before do
        CS.current_country = us_country_code
        stub_const 'ENV', ENV.to_h.merge('USE_CITIES_GEM' => 'false')
      end

      context 'when is not a state from the us' do
        let(:state_code) { 'AA' }
        let(:cities_for_select) { [] }

        it { is_expected.to be_blank }
      end

      it 'returns the cities from the state in the us' do
        expect(subject).to match_array(us_cities_for_select)
      end
    end

    context 'when using state_cities gem' do
      before { stub_const 'ENV', ENV.to_h.merge('USE_CITIES_GEM' => 'true') }

      it 'returns the set of cities for the given country' do
        expect(subject).to eq(cities_for_select)
      end
    end
  end
end
