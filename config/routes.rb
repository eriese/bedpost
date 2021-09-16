Rails.application.routes.draw do
	devise_scope :user_profile do
		get 'signup', to: 'user_profiles/registrations#new', as: :new_user_profile_registration
		post 'profile', to: 'user_profiles/registrations#create'
		get 'signup/cancel', to: 'user_profiles/registrations#cancel', as: :cancel_user_profile_registration
		get 'profile', to: 'user_profiles/registrations#edit', as: :edit_user_profile_registration
		patch 'profile', to: 'user_profiles/registrations#update', as: :user_profile_registration
		put 'profile', to: 'user_profiles/registrations#update'
		delete 'profile', to: 'user_profiles/registrations#destroy', as: :destroy_user_profile_registration
		get 'uniqueness', to: 'user_profiles/registrations#unique'
		if ENV['IS_BETA']
			get 'beta_signup', to: 'user_profiles/registrations#new_beta', as: :beta_registration
		end
	end
	devise_for :user_profiles, skip: [:registrations], path: '', singular: :user_profile, path_names: {
		sign_in: 'login', sign_out: 'logout',
		password: 'recover', confirmation: 'confirm',
		unlock: 'unlock',
	}, controllers: {
		sessions: 'user_profiles/sessions'
	}
	# authenticated :user_profile do
	# root to: 'user_profiles#show'
	# end

	get 'partners/uniqueness', to: 'partnership_whos#unique'

	resources :partners, controller: 'partnerships', as: 'partnerships' do
		resource :profile, except: [:index, :new, :create]
		get 'who', to: 'partnership_whos#edit'
		put 'who', to: 'partnership_whos#update'
		patch 'who', to: 'partnership_whos#update'
		get 'uniqueness', to: 'partnership_whos#unique'
	end

	resources :encounters
	get 'sti_tests/uniqueness', to: 'sti_tests#unique'
	get 'sti_tests/:current_tested_on/uniqueness', to: 'sti_tests#unique'
	resources :sti_tests, param: :tested_on

	get 'first_time', to: 'tours#index'
	post 'first_time', to: 'tours#create'
	resources :tours, only: [:show, :update]
	resources :terms, only: [:show, :update]

	resource :overview, only: [:show, :create]

	get 'feedback/*feedback_type', to: 'trello#new', as: :feedback
	post 'feedback/*feedback_type', to: 'trello#create'

	if ENV['IS_BETA']
		get 'beta', to: 'beta#index'
		post 'beta', to: 'beta#create'
		post 'beta_google', to: 'beta#create_google'
	end

	get '*static', to: 'static#static_or_404', as: :static

	# root to: redirect('/signup')
	root to: 'user_profiles#show'
	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
