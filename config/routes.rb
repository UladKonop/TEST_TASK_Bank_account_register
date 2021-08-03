# frozen_string_literal: true

Rails.application.routes.draw do
  resources :accounts, only: %i[show create destroy]
  resources :users
  resources :transactions, only: %i[], param: :identification_number do
    post 'deposit', on: :member
    post 'transfer', on: :collection
  end
  resources :reports, only: :index
end
