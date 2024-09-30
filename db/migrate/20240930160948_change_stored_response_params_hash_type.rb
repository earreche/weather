# frozen_string_literal: true

class ChangeStoredResponseParamsHashType < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up do
        change_column :stored_responses, :params_hash, :jsonb, using: 'to_jsonb(params_hash)'
      end
      dir.down do
        change_column :stored_responses, :params_hash, :json, using: 'to_json(params_hash)'
      end
    end
  end
end
