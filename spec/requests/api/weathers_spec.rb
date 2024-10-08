# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API::TodoItems', type: :request do
  let(:expected_response) do
    { id: todo_item.id, name: todo_item.name, status: todo_item.status, todo_list_id: todo_list.id }
  end

  describe 'GET /weather/' do
    subject do
      post api_todo_list_todo_items_path(todo_list), params: attributes
      response
    end

    let(:valid_attributes) { { name: 'valid' } }
    let(:invalid_attributes) { { invalid_attribute: 'invalid' } }

    context 'with valid parameters' do
      let(:attributes) { valid_attributes }
      let(:todo_item) { TodoItem.last }
      let(:expected_response) { { id: todo_item.id, name: todo_item.name } }

      it 'renders a successful response' do
        expect(subject).to be_successful
      end

      it 'creates a new TodoItem' do
        expect { subject }.to change(TodoItem, :count).by(1)
      end

      it 'returns the created todo_item' do
        expect(JSON.parse(subject.body, symbolize_names: true)).to eq(expected_response)
      end
    end

    context 'with invalid parameters' do
      let(:attributes) { invalid_attributes }

      it 'does not create a new TodoItem' do
        expect { subject }.not_to change(TodoItem, :count)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        expect(subject).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
