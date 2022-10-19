Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get '/merchants/find_all', to: 'merchants#find_all'
      get 'merchants/find', to: 'merchants#find'
      resources :merchants, only: [:index, :show] do
        resources :items, only: [:index], to: 'merchant_items#index'
      end
      get '/items/find', to: 'items#find'
      resources :items  do
        resources :merchant, only: [:index], to: 'item_merchants#index'
      end
    end
  end
end