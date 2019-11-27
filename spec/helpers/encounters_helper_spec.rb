require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the EncountersHelper. For example:
#
# describe EncountersHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe EncountersHelper, type: :helper do
  describe '#display_schedule' do
  	context 'with an unforced schedule' do
  		before :each do
  			@encounter = double("Encounter", {
	  			risks: {
	  				hpv: Diagnosis::TransmissionRisk::HIGH,
	  				hsv: Diagnosis::TransmissionRisk::MODERATE,
	  				hiv: Diagnosis::TransmissionRisk::MODERATE,
	  				hep_c: Diagnosis::TransmissionRisk::NEGLIGIBLE
	  			},
	  			schedule: {
	  				Date.new(2019, 11, 3) => [:hiv],
	  				Date.new(2019, 10, 31) => [:hpv, :hsv],
	  				routine: [:hep_c]
	  			}
	  		})

	  		@output = raw(helper.display_schedule(@encounter) do
	  			'click me'
	  		end)

	  		@root = Capybara::Node::Simple.new(@output)
  		end
  		it 'outputs a sorted list of test dates and the diagnoses they apply to, including routine testing' do
	  		expect(@root).to have_selector('ul.schedule-show')
	  		date1 = Date.new(2019, 10, 31)
	  		date2 = Date.new(2019, 11, 3)
	  		hiv = t(:hiv, scope: 'diagnosis.name_casual')
	  		hpv = t(:hpv, scope: 'diagnosis.name_casual')
	  		hsv = t(:hsv, scope: 'diagnosis.name_casual')
	  		hep_c = t(:hep_c, scope: 'diagnosis.name_casual')
	  		routine = CGI::escapeHTML(t('encounters.show.advice.routine'))

	  		expect(@output).to match(/.*schedule-date.*Oct.*31.*#{hpv}, #{hsv}.*schedule-date.*Nov.*03.*#{hiv}.*schedule-routine.*#{routine}.*click me.*#{hep_c}/)
	  	end

	  	it 'does not include a key' do
	  		expect(@root).to have_no_content(t('encounters.show.advice.key_html'))
	  	end
  	end

  	context 'with a forced schedule' do
  		before :each do
  			@encounter = double("Encounter", {
	  			risks: {
	  				hpv: Diagnosis::TransmissionRisk::HIGH,
	  				hsv: Diagnosis::TransmissionRisk::MODERATE,
	  				hiv: Diagnosis::TransmissionRisk::MODERATE,
	  				hep_c: Diagnosis::TransmissionRisk::NEGLIGIBLE
	  			},
	  			schedule: {
	  				Date.new(2019, 11, 3) => [:hiv, :hep_c],
	  				Date.new(2019, 10, 31) => [:hpv, :hsv]
	  			}
	  		})

	  		@block_obj = double("Block Object", {call: "Called"})

	  		@output = raw(helper.display_schedule(@encounter) do
	  			@block_obj.call
	  		end)

	  		@root = Capybara::Node::Simple.new(@output)
  		end

  		it 'does not include the routine testing section' do
  			expect(@root).to have_no_content(t('encounters.show.advice.routine'))
  		end

  		it 'puts an asterisk next to the name of diagnoses with lower risks' do
  			hep_c = t(:hep_c, scope: 'diagnosis.name_casual')
  			expect(@root).to have_content("#{hep_c}*")
  		end

  		it 'includes a key' do
  			key = Capybara::Node::Simple.new(t('encounters.show.advice.key_html'))
	  		expect(@root).to have_content(key.text)
	  	end

	  	it 'does not run the block' do
	  		expect(@block_obj).to_not have_received(:call)
	  	end
  	end
  end
end
