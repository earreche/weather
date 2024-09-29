# frozen_string_literal: true

class CreateStoredResponses < ActiveRecord::Migration[7.0]
  def change
    create_table :stored_responses do |t|
      t.string :api_client, null: false
      t.string :method_name, null: false
      t.json :params_hash, null: false
      t.json :api_response, null: false
      t.datetime :valid_until, null: false

      t.timestamps
    end
  end
end
