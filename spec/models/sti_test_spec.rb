require 'rails_helper'

RSpec.describe StiTest, type: :model do
	describe '#to_param' do
		it 'uses a format that parses back to the proper date' do
			tst = build(:sti_test)
			param = tst.to_param
			expect(Date.parse(param)).to eq tst.tested_on
		end
	end

	describe '#tested_on=' do
		it 'can parse from a string' do
			given_string = I18n.localize(Date.current, format: described_class::PARAM_FORMAT)
			tst = described_class.new(tested_on: given_string)
			expect(tst.tested_on).to eq Date.parse(given_string)
		end

		it 'always sets to the beginning of the day' do
			given_date = Date.current
			tst = described_class.new(tested_on: given_date)
			expect(tst.tested_on).to eq given_date.beginning_of_day
		end
	end
end
