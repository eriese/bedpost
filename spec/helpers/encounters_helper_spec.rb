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
			before do
				@encounter = instance_double('Encounter', risks:
				{
					hpv: Diagnosis::TransmissionRisk::HIGH,
					hsv: Diagnosis::TransmissionRisk::MODERATE,
					hiv: Diagnosis::TransmissionRisk::MODERATE,
					hep_c: Diagnosis::TransmissionRisk::NEGLIGIBLE
				}, schedule: {
					Date.new(2019, 11, 3) => %i[hiv],
					Date.new(2019, 10, 31) => %i[hpv hsv],
					routine: %i[hep_c]
				})

				@output = raw(helper.display_schedule(@encounter) do
					'click me'
				end)

				@root = Capybara::Node::Simple.new(@output)
			end

			it 'outputs a sorted list of test dates and the diagnoses they apply to, including routine testing' do
				hiv, hpv, hep_c, hsv = %i[hiv hpv hep_c hsv].map do |i|
					t(i, scope: 'diagnosis.name_casual')
				end
				routine = CGI.escapeHTML(t('encounters.show.advice.routine'))

				expect(@output).to match(/<ul class="schedule-show".*schedule-date.*Oct.*31.*#{hpv}, #{hsv}.*schedule-date.*Nov.*03.*#{hiv}.*schedule-routine.*#{routine}.*click me.*#{hep_c}/)
			end

			it 'does not include a key' do
				expect(@root).to have_no_content(t('encounters.show.advice.key_html'))
			end
		end

		context 'with a forced schedule' do
			before do
				@encounter = instance_double("Encounter", risks:
					{
						hpv: Diagnosis::TransmissionRisk::HIGH,
						hsv: Diagnosis::TransmissionRisk::MODERATE,
						hiv: Diagnosis::TransmissionRisk::MODERATE,
						hep_c: Diagnosis::TransmissionRisk::NEGLIGIBLE
					}, schedule: {
						Date.new(2019, 11, 3) => %i[hiv hep_c],
						Date.new(2019, 10, 31) => %i[hpv hsv]
					})

				@block_obj = instance_double('Block', call: 'Called')

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
				expect(@block_obj).not_to have_received(:call)
			end
		end
	end

	describe '#display_risks' do
		before do
			helper.instance_variable_set(:@virtual_path, 'encounters.show')
		end

		it 'renders a ul with class risks-show' do
			risks = {
				hpv: Diagnosis::TransmissionRisk::HIGH,
				hsv: Diagnosis::TransmissionRisk::MODERATE,
				hiv: Diagnosis::TransmissionRisk::MODERATE,
				hep_c: Diagnosis::TransmissionRisk::NEGLIGIBLE
			}

			encounter = instance_double(
				'Encounter',
				risks: risks
			)

			output = helper.display_risks(encounter)
			root = Capybara::Node::Simple.new(output)
			expect(root).to have_selector('ul.risks-show')
		end

		context 'with no risks' do
			before do |example|
				obj_type = example.metadata[:object] || Encounter
				@risk_obj = instance_double(obj_type, risks: {})
				allow(@risk_obj).to receive(:is_a?) { |arg| arg == obj_type }
				@output = helper.display_risks(@risk_obj)
				@root = Capybara::Node::Simple.new(@output)
			end

			it 'adds a single li' do
				expect(@root).to have_selector('li', count: 1)
			end

			it 'says there is no risk on the encounter', object: Encounter do
				expected_text = t('encounters.show.risks.no_risks')
				expect(@root).to have_selector('li.risk-0', text: expected_text, count: 1)
			end

			it 'says there is no risk on the contact', object: EncounterContact do
				expected_text = t('encounters.show.risks.no_risks_contact')
				expect(@root).to have_selector('li.risk-0', text: expected_text)
			end
		end

		context 'with risks' do
			before do
				@risks = {
					hpv: Diagnosis::TransmissionRisk::HIGH,
					hsv: Diagnosis::TransmissionRisk::MODERATE,
					hiv: Diagnosis::TransmissionRisk::MODERATE,
					hep_c: Diagnosis::TransmissionRisk::NEGLIGIBLE
				}

				@encounter = instance_double(
					'Encounter',
					risks: @risks
				)

				@output = helper.display_risks(@encounter)
				@root = Capybara::Node::Simple.new(@output)
			end

			it 'attaches an li for each risk level' do
				expect(@root).to have_selector('li', count: 3)
			end

			it 'groups diagnoses of the same risk' do
				risk_list = %i[hsv hiv].map { |d| t(d, scope: 'diagnosis.name_casual') }
				expected_text = risk_list.join(t 'join_delimeter')
				expect(@root).to have_selector("li.risk-#{Diagnosis::TransmissionRisk::MODERATE} .diagnoses", text: expected_text)
			end
		end
	end
end
