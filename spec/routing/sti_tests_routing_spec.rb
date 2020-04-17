require 'rails_helper'

RSpec.describe StiTestsController, type: :routing do
	describe 'routing' do
		it 'uses #tested_on as the parameter' do
			tst = build(:sti_test)
			expect(get: sti_test_path(tst)).to route_to('sti_tests#show', tested_on: tst.to_param)
		end
	end
end
