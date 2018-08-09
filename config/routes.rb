# frozen_string_literal: true

Rails.application.routes.draw do
  # default_url_options host: "example.com"
  mount_devise_token_auth_for "User", at: "auth"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # resources :users

  # root 'welcome#index'
end
