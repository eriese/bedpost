require 'rails_helper'

RSpec.describe UserProfiles::RegistrationsController, type: :routing do
  describe 'routing' do
  	context 'custom routes' do
	  	it 'routes GET /signup to #new' do
	  		expect(get: '/signup').to route_to('user_profiles/registrations#new')
	  	end

	  	it 'routes POST /profile to #create' do
	  		expect(post: '/profile').to route_to('user_profiles/registrations#create')
	  	end

	  	it 'routes GET /signup/cancel to #cancel' do
	  		expect(get: '/signup/cancel').to route_to('user_profiles/registrations#cancel')
	  	end

	  	it 'routes GET /profile to #edit' do
	  		expect(get: '/profile').to route_to('user_profiles/registrations#edit')
	  	end

	  	it 'routes PATCH /profile to #update' do
	  		expect(patch: '/profile').to route_to('user_profiles/registrations#update')
	  	end

	  	it 'routes PUT /profile to #update' do
	  		expect(put: '/profile').to route_to('user_profiles/registrations#update')
	  	end

	  	it 'routes DELETE /profile to #destroy' do
	  		expect(delete: '/profile').to route_to('user_profiles/registrations#destroy')
	  	end
	  end
  end
end
