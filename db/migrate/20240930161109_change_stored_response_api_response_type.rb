# frozen_string_literal: true

class ChangeStoredResponseApiResponseType < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up do
        change_column :stored_responses, :api_response, :jsonb,
                      using: 'to_jsonb(stored_responses.api_response)'
      end
      dir.down do
        change_column :stored_responses, :api_response, :json,
                      using: 'to_json(stored_responses.api_response)'
      end
    end
  end
end
