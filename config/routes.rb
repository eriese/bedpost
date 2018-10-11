Rails.application.routes.draw do
  resources :profiles
  resource :user_profile
  get 'signup', to: 'user_profiles#new'

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  get 'retrieve', to: 'resets#new'
  post 'retrieve', to: 'resets#create'
  get 'reset', to: 'resets#edit'

  resource :reset, only: [:update]

  #TODO this is temporary
  root to: 'user_profiles#new'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
