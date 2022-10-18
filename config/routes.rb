Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :merchants, only: [:index, :show]
      resources :items  do
        resources :merchant, only: [:index], to: 'item_merchants#index'
      end
    end
  end
end


