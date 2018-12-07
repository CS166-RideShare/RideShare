Rails.application.routes.draw do
  root 'main_pages#home'

  get  '/emergency', to: 'main_pages#emergency'
  get  '/signup',  to: 'users#new'
  post '/signup',  to: 'users#create'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  post '/request/new', to: 'rides#create_request'
  delete '/request', to: 'rides#cancel_request'
  get '/request', to: 'rides#show_request'
  patch '/request', to: 'rides#take_request'

  resources :users

  mount ActionCable.server => '/cable'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
