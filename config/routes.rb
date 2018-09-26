Rails.application.routes.draw do
  resources :profiles
  resource :user_profile
  get 'signup'  => 'user_profiles#new'

  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'

  #TODO this is temporary
  root to: 'sessions#new'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
