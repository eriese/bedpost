require 'rails_helper'

RSpec.describe Tour, type: :model do
	describe 'class methods' do
		describe '#by_page' do
			after do
				described_class.destroy_all
			end

			it 'finds the tour by its page_name' do
				tour = create(:tour)
				result = described_class.by_page(tour.page_name)
				expect(result).to eq tour
			end

			it 'caches the found tour' do
				tour = create(:tour)
				allow(Rails.cache).to receive(:fetch)
				described_class.by_page(tour.page_name)
				expect(Rails.cache).to have_received(:fetch).with("page_name:#{tour.page_name}", namespace: described_class.name)
			end

			it 'strips ids out of page names' do
				orig_page_name = Rails.application.routes.url_helpers.partnership_encounter_path(build_stubbed(:partnership), build_stubbed(:encounter))
				# strip the slashes out because this is how it comes in from the front
				orig_page_name.tr!('/', '_')
				stripped_page_name = orig_page_name.gsub(described_class::STRIP_IDS_REGEX, '')
				allow(Rails.cache).to receive(:fetch)
				described_class.by_page!(orig_page_name)
				expect(Rails.cache).to have_received(:fetch).with("page_name:#{stripped_page_name}", namespace: described_class.name)
			end
		end

		describe '#by_page!' do
			it 'does not raise an error on document not found' do
				expect { described_class.by_page!('page') }.not_to raise_error
			end
		end
	end
end
