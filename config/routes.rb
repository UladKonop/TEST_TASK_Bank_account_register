Rails.application.routes.draw do
  resources :accounts, only: %i[show create destroy]
  resources :users
  resources :transactions, only: %i[], param: :account_id do
    post 'deposit', on: :member 
  end
   # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
