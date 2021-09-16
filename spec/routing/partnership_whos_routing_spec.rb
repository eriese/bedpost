require 'rails_helper'

RSpec.describe PartnershipWhosController, type: :routing do
	describe 'routing' do
		context "scoped under '/partners'" do
			it 'routes to #unique via GET at /uniqueness' do
				expect(:get => 'partners/uniqueness?uid=12345').to route_to('partnership_whos#unique', uid: '12345')
			end
		end

		context 'nested under partners resource' do
			it 'routes to #edit' do
				expect(:get => 'partners/1/who').to route_to('partnership_whos#edit', :partnership_id => '1')
			end

			it 'routes to #update via PATCH' do
				expect(:patch => 'partners/1/who').to route_to('partnership_whos#update', :partnership_id => '1')
			end

			it 'routes to #update via PATCH' do
				expect(:put => 'partners/1/who').to route_to('partnership_whos#update', :partnership_id => '1')
			end
		end
	end
end
