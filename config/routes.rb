Rails.application.routes.draw do
  resources :accounts, only: %i[show create destroy]
  resources :users
  resources :transactions, only: %i[], param: :identification_number do
    post 'deposit', on: :member 
    post 'transfer', on: :collection
  end

   # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
