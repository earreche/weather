class ChangeStoredResponseApiResponseType < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up { change_column :stored_responses, :api_response, :jsonb, using: 'to_jsonb(stored_responses.api_response)' }
      dir.down { change_column :stored_responses, :api_response, :json, using: 'to_json(stored_responses.api_response)' }
    end
  end
end
