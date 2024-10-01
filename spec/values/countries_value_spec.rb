# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CountriesValue do
  let(:us_country_code) { 'US' }

  describe '.country' do
    subject { described_class.new(country_code).country }

    let(:country_code) { CS.countries.keys.sample }

    context 'when not using cities_states gem' do
      let(:country_code) { [CS.countries.keys.sample, nil].sample }

      before { stub_const 'ENV', ENV.to_h.merge('USE_CITIES_GEM' => 'false') }

      it { is_expected.to eq(us_country_code) }
    end

    context 'when using cities_states gem' do
      before { stub_const 'ENV', ENV.to_h.merge('USE_CITIES_GEM' => 'true') }

      it { is_expected.to eq(country_code) }
    end
  end

  describe '.states' do
    subject { described_class.new(country_code).states }

    let(:states_for_select) { CS.states(country_code).invert }
    let(:country_code) { CS.countries.keys.sample }

    context 'when not using cities_states gem' do
      let(:country_code) { CS.countries.except(us_country_code).keys.sample }
      let(:us_states_for_select) { CS.states(us_country_code).invert }

      before { stub_const 'ENV', ENV.to_h.merge('USE_CITIES_GEM' => 'false') }

      it 'always returns the states from the us' do
        expect(subject).to eq(us_states_for_select)
      end
    end

    context 'when using cities_states gem' do
      before { stub_const 'ENV', ENV.to_h.merge('USE_CITIES_GEM' => 'true') }

      it 'returns the set of states for the given country' do
        expect(subject).to eq(states_for_select)
      end
    end
  end
end
