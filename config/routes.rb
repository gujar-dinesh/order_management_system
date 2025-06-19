require 'sidekiq/web'

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :orders, only: [:create, :show, :index] do
    member do
      put :update_status
      post :cancel
    end
  end

  resources :inventory_items, only: [:index, :create, :update, :destroy]


  mount Sidekiq::Web => '/sidekiq'

  # Defines the root path route ("/")
  # root "posts#index"
end
