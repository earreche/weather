# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StoredResponse, type: :model do
  describe 'validations' do
    it 'checks presence', factory: :stub do
      expect(subject).to validate_presence_of(:api_client)
      expect(subject).to validate_presence_of(:method_name)
      expect(subject).to validate_presence_of(:params_hash)
      expect(subject).to validate_presence_of(:api_response)
      expect(subject).to validate_presence_of(:valid_until)
    end
  end

  describe 'valid_response?' do
    subject { stored_response.valid_response?(valid_until) }

    let(:valid_until) { stored_response.valid_until - 30.minutes }
    let(:stored_response_trait) { %i[weather_query_by_position weather_query_for_city].sample }

    context 'when the response is not persisted' do
      let(:stored_response) { build(:stored_response, stored_response_trait) }

      it { is_expected.to be false }
    end

    context 'when the response is persisted' do
      let(:stored_response) { create(:stored_response, stored_response_trait) }

      it { is_expected.to be true }

      context 'when the response is persisted' do
        let(:valid_until) { stored_response.valid_until + 30.minutes }

        it { is_expected.to be false }
      end
    end
  end
end
