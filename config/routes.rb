Rails.application.routes.draw do
  devise_scope :user_profile do
    root to: 'user_profiles#show'
    get 'signup', to: 'user_profiles/registrations#new', as: :new_user_profile_registration
    post 'profile', to: 'user_profiles/registrations#create'
    get 'signup/cancel', to: 'user_profiles/registrations#cancel', as: :cancel_user_profile_registration
    get 'profile', to: 'user_profiles/registrations#edit', as: :edit_user_profile_registration
    patch 'profile', to: 'user_profiles/registrations#update', as: :user_profile_registration
    put 'profile', to: 'user_profiles/registrations#update'
    delete 'profile/delete', to: 'user_profiles/registrations#destroy'
  end
  devise_for :user_profiles, skip: [:registrations], path: "", singular: :user_profile, path_names: {
      sign_in: 'login', sign_out: 'logout',
      password: 'recover', confirmation: 'confirm',
      unlock: 'unlock',
  }

  scope "partners" do
    resource :profile, only: [:new, :create], as: :dummy_profile
    get 'who', to: 'partnership_whos#new'
    post 'who', to: 'partnership_whos#create'
  end

  resources :partners, controller: "partnerships", as: "partnerships" do
    resource :profile, except: [:index, :new, :create]
    get 'who', to: 'partnership_whos#new'
    put 'who', to: 'partnership_whos#update'
    patch 'who', to: 'partnership_whos#update'
    resources :encounters
  end

  get 'encounters/who', to: 'encounter_whos#new'
  post 'encounters/who', to: 'encounter_whos#create'

  resources :encounters, only: [:index]

  resource :user_profile, except: [:show, :new]

  #TODO this is temporary
  root to: 'devise/sessions#new'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
