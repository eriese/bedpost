require 'rails_helper'

RSpec.describe VuelidateForm::Tags::Tooltip, type: :helper do
	def stub_tag(options = {})
		described_class.new('object_name', :name, helper, options)
	end

	describe '#always_shown_tooltip' do
		it 'renders an aside with class tippy-popper' do
			tag = stub_tag
			tag_node = Capybara.string(tag.always_shown_tooltip)
			expect(tag_node).to have_xpath('/html/body/aside', class: 'tippy-popper')
		end

		it 'follows the same structure as tippy' do
			tag = stub_tag
			tag_node = Capybara.string(tag.always_shown_tooltip)
			expected_css = '.tippy-popper>.tippy-tooltip>.tippy-arrow+.tippy-content'
			expect(tag_node).to have_css(expected_css)
		end

		it 'adds the given theme as #{theme}-theme on the .tippy-tooltip element' do
			tag = stub_tag
			theme = described_class::THEME
			tag_output = tag.always_shown_tooltip({'theme' => theme})
			tag_node = Capybara.string(tag_output)
			expect(tag_node).to have_css(".tippy-tooltip.#{theme}-theme")
		end

		it 'adds the id #{tag_id}-tooltip-content to the .tippy-tooltip element' do
			tag = stub_tag
			tag_node = Capybara.string(tag.always_shown_tooltip)
			expected_css = ".tippy-tooltip##{tag.send :tag_id}-tooltip-content"
			expect(tag_node).to have_css(expected_css)
		end

		it 'does not add a slot scope' do
			tag = stub_tag({slot_scope: 'sc'})
			tag_node = Capybara.string(tag.always_shown_tooltip)
			expect(tag_node).to_not have_css('[slot_scope]')
		end
	end

	describe '#render' do
		it 'adds the default theme to the tooltip element' do
			tag = stub_tag
			tag_node = Capybara.string(tag.render)
			expect(tag_node).to have_css("tooltip[theme=#{described_class::THEME}]")
		end

		it 'calls #show_always if passed show_always: true' do
			tag = stub_tag({show_always: true})
			allow(tag).to receive(:always_shown_tooltip)
			tag.render
			expect(tag).to have_received(:always_shown_tooltip)
		end

		it 'returns a tooltip object' do
			tag = stub_tag
			output = tag.render
			expect(output).to match(/\A<tooltip.*<\/tooltip>\z/)
		end
	end

	describe '#add_default_name_and_id' do
		it 'adds the appropriate target id by default' do
			tag = stub_tag
			options = {}
			tag.add_default_name_and_id(options)
			expect(options['to-selector']).to eq '#object_name_name'
		end

		it 'adds the given namespace to the target id by default' do
			tag = stub_tag
			options = {'namespace' => 'given_namespace'}
			tag.add_default_name_and_id(options)
			expect(options['to-selector']).to start_with 'given_namespace'
		end
	end
end
