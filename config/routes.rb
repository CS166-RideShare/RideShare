Rails.application.routes.draw do
  get 'sessions/new'
  get '/home', to: 'main_pages#home'

  get  '/signup',  to: 'user#new'
  post '/signup',  to: 'user#create'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  resources :user
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
