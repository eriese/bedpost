require 'rails_helper'

RSpec.describe ToursController, type: :routing do
	describe 'routing' do
		it 'routes #index to /first_time' do
			expect(get: '/first_time').to route_to('tours#index')
		end

		it 'routes #create to /first_time' do
			expect(post: '/first_time').to route_to('tours#create')
		end

		it 'routes to #show' do
			expect(get: '/tours/1').to route_to('tours#show', id: '1')
		end

		it 'routes to #update via PUT' do
			expect(put: '/tours/1').to route_to('tours#update', id: '1')
		end

		it 'routes to #update via PATCH' do
			expect(patch: '/tours/1').to route_to('tours#update', id: '1')
		end
	end
end
