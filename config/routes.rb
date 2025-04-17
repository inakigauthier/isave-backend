# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      get 'customers/:id/portfolios', to: 'portfolios#index'

      post 'customers/:customer_id/portfolios/:id/deposit', to: 'portfolios#deposit'
      post 'customers/:customer_id/portfolios/:id/withdraw', to: 'portfolios#withdraw'
      post 'customers/:customer_id/portfolios/:id/arbitrate', to: 'portfolios#arbitrate'
    end
  end
end
