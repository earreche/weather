# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get '/query_by_position', to: 'public#query_by_position'

  root "public#index"
end
