require 'rails_helper'

RSpec.describe Tour, type: :model do
  context 'class methods' do
  	describe '#by_page' do
  		after :each do
  			Tour.destroy_all
  		end

  		it 'finds the tour by its page_name' do
  			tour = create(:tour)
  			result = Tour.by_page(tour.page_name)
  			expect(result).to eq tour
  		end

  		it 'caches the found tour' do
  			tour = create(:tour)
  			expect(Rails.cache).to receive(:fetch)
  			Tour.by_page(tour.page_name)
  		end
  	end

    describe '#by_page!' do
      it 'does not raise an error on document not found' do
        expect{Tour.by_page!("page")}.to_not raise_error
      end
    end
  end
end
