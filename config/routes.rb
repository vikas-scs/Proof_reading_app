Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :admins
  devise_for :users, :controllers =>{ registrations: "users/registrations"} 
  root "post#index"
  get 'post/index', to: 'post#index'
  get "post/new", to:"post#new", as: :new_post
  post 'post/:id', to: 'post#create'
  get 'post/:id', to: 'post#show', as: :post
  get 'post/:id/edit', to: 'post#edit', as: :edit_post
  patch 'post/:id', to: 'post#update', as: :update
  delete 'post/:id', to: 'post#destroy'

  get 'user_wallet/index', to: 'user_wallet#index', as: :wallets
  get "user_wallet/:id", to:"user_wallet#new", as: :new_wallet
  post 'user_wallet/:id', to: 'user_wallet#create'
  get 'user_wallet/:id', to: 'user_wallet#show', as: :wallet
  get 'user_wallet/:id/edit', to: 'user_wallet#edit', as: :edit_wallet
  patch 'user_wallet/:id/edit', to: 'user_wallet#update', as: :wallet_update
  put 'user_wallet/:id', to: 'user_wallet#update'
end
