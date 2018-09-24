# frozen_string_literal: true

Rails.application.routes.draw do
  # default_url_options host: "example.com"
  mount_devise_token_auth_for "User", at: "auth"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :lots
  resources :bids, only: [:create]
  resources :orders, except: [:index, :destroy]

  put "order_status/:id", action: :status_update, controller: "orders_status"

  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"
  mount ActionCable.server, at: "/cable"
end
