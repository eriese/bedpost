Rails.application.routes.draw do
  scope "/partners" do
    resource :profile, only: [:new, :create]
    # resource :who
    get '/who', to: 'partnership_whos#new'
    post '/who', to: 'partnership_whos#create'

  end

  resources :partners, controller: "partnerships", as: "partnerships" do
    resource :profile, except: [:index, :new, :create]
    get '/who', to: 'partnership_whos#new'
    put '/who', to: 'partnership_whos#update'
    patch '/who', to: 'partnership_whos#update'
    resources :encounters
  end

  resources :encounters, only: [:index]

  resource :user_profile, except: [:show, :new]
  get 'signup', to: 'user_profiles#new'

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  get 'retrieve', to: 'resets#new'
  post 'retrieve', to: 'resets#create'
  get 'reset', to: 'resets#edit'

  resource :reset, only: [:update]

  root to: 'user_profiles#show', constraints: lambda {|request|
    request.session[:user_id] != nil
  }

  #TODO this is temporary
  root to: 'user_profiles#new'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
