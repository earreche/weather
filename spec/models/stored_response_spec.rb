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
end
