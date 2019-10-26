require "rails_helper"

RSpec.describe FirstTimesController, type: :routing do
	describe 'routing' do
		it 'routes #index to /first_time' do
			expect(get: '/first_time').to route_to('first_times#index')
		end

		it 'routes to #show' do
			expect(get: '/first_time/1').to route_to('first_times#show', id: '1')
		end

		it 'routes to #update via PUT' do
			expect(put: '/first_time/1').to route_to('first_times#update', id: '1')
		end

		it 'routes to #update via PATCH' do
			expect(patch: '/first_time/1').to route_to('first_times#update', id: '1')
		end
	end
end
