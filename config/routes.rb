Rails.application.routes.draw do
  root 'main_pages#home'

  get  '/signup',  to: 'users#new'
  post '/signup',  to: 'users#create'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  get '/request/new', to: 'rides#new_request'
  post '/request/new', to: 'rides#create_request'
  delete '/request', to: 'rides#cancel_request'
  get '/request', to: 'rides#show_request'
  patch '/request', to: 'rides#take_request'

  resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
