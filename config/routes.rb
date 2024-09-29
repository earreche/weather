# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get '/query_by_position', to: 'public#query_by_position'
  get '/query_by_city', to: 'public#query_by_city'
  get '/filter_select_location', to: 'public#filter_select_location'

  root 'public#index'
end
