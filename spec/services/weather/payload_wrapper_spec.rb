# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Weather::PayloadWrapper do
  include_context 'new weather wrapper context'

  describe '#current' do
    subject { described_class.new(payload).current }

    it { is_expected.to eq(current['current']) }
  end

  describe '#current_weather' do
    subject { described_class.new(payload).current_weather }

    it { is_expected.to eq(current_weather.dig('weather', 0)) }
  end

  describe '#hourly' do
    subject { described_class.new(payload).hourly }

    it { is_expected.to eq(hourly['hourly']) }
  end

  describe '#daily' do
    subject { described_class.new(payload).daily }

    it { is_expected.to eq(daily['daily']) }
  end
end
