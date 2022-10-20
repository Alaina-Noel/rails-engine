Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get '/merchants/find_all', to: 'merchant_searches#find_all'
      get 'merchants/find', to: 'merchant_searches#find'
      resources :merchants, only: [:index, :show] do
        resources :items, only: [:index], controller: 'merchants/items'
      end
      get '/items/find', to: 'item_searches#find'
      resources :items  do
        resources :merchant, only: [:index], controller: 'items/merchants'
      end
    end
  end
end
