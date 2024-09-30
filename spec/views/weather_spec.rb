# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'weather', type: :view do
  subject do
    render partial: 'public/weather', locals: { weather: weather_presenter, location: location }
    Nokogiri::HTML(rendered)
  end

  include_context 'new weather wrapper context'

  let(:payload_wrapper) { Weather::PayloadWrapper.new(payload) }
  let(:weather_presenter) { Weather::WeatherPresenter.new(payload_wrapper) }
  let(:location) { 'custom location' }

  it 'has correct titles' do
    expect(subject.css('h3')).to have_content("Current weather at #{location}")
    expect(subject.css('h5')).to have_content('Upcoming 5 hours')
    expect(subject.css('h5')).to have_content('Forecast for the next 5 days')
  end
end
