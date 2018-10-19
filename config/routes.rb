Rails.application.routes.draw do
	
	root 'main_pages#home'
  get '/home', to: 'main_pages#home'

  get  '/signup',  to: 'user#new'
  post '/signup',  to: 'user#create'
  resources :user
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
