# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public' do
  let(:params) { '' }

  describe 'GET /' do
    subject do
      get root_path
      response
    end

    it { is_expected.to have_http_status(:ok) }
  end

  describe 'GET /query_by_position' do
    subject do
      get(query_by_position_path(params), as: :turbo_stream)
      response
    end

    context 'when a parameter is missing' do
      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'when parameters are sent' do
      let(:latittude) { '-34.901112' }
      let(:longitude) { '-56.164532' }
      let(:api_response) { { weather_overview: 'The current weather is super nice' } }
      let(:params) do
        {
          lat: latittude,
          long: longitude
        }
      end

      it 'calls the weather API with correct parameters and returns ok' do
        expect_any_instance_of(Weather::ApiClientService).to receive(:query_by_position).with(
          latittude: latittude, longitude: longitude
        ).and_return(api_response)

        expect(subject).to have_http_status(:ok)
      end
    end
  end
end
