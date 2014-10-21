Rails.application.routes.draw do
  resources :users
  resources :tweets

  root to: 'tweets#index'

  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'
  get '/auth/signin' => 'sessions#signin'
end
