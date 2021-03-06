Rails.application.routes.draw do
  root 'main_pages#home'

  get  '/front', to: 'main_pages#front'
  get  '/emergency', to: 'main_pages#emergency'
  get  '/signup',  to: 'users#new'
  post '/signup',  to: 'users#create'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  post '/user/:id/message', to: 'users#send_message', as: 'user_message'
  get '/users/:id/drivings', to: 'users#driving_index', as: 'user_driving'
  get '/users/:id/requests', to: 'users#request_index', as: 'user_request'
  delete '/user/:id/notices', to: 'users#clear_notices', as: 'user_notice'
  get '/users/:id/trips', to: 'users#trips', as: 'user_trip'

  post '/request/new', to: 'rides#create_request'
  delete '/request', to: 'rides#cancel_request'
  get '/request', to: 'rides#show_request'
  patch '/request', to: 'rides#take_request'

  get '/ride/:id/details', to: 'rides#details', as: 'ride_details'
  delete '/ride', to: 'rides#cancel_ride'
  patch '/ride', to: 'rides#finish_ride'
  get 'ride/new', to: 'rides#new_ride'

  post 'ride/:rid/review/:role', to: 'rides#review_ride', as: 'ride_review'
  get 'trip/:rid/review/:target', to: 'rides#review_trip', as: 'trip_review'

  resources :users

  mount ActionCable.server => '/cable'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
