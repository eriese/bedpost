require 'rails_helper'

RSpec.describe VuelidateForm::Tags::Tooltip, type: :helper do
	def stub_tag(options = {})
		described_class.new('object_name', :name, helper, options)
	end

	describe '#render' do
		it 'returns a tooltip object' do
			tag = stub_tag
			output = tag.render
			expect(output).to match(%r{\A<tooltip.*<\/tooltip>\z})
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
			options = { 'namespace' => 'given_namespace' }
			tag.add_default_name_and_id(options)
			expect(options['to-selector']).to start_with 'given_namespace'
		end

		it 'adds the appropriate id with -tooltip-content' do
			tag = stub_tag
			options = {}
			tag.add_default_name_and_id(options)
			expect(options['id']).to eq 'object_name_name-tooltip-content'
		end
	end

	describe '#add_vue_options' do
		it 'adds the given slot scope as :use-scope' do
			options = { 'slot_scope' => 'sc' }
			tag = stub_tag
			tag.add_vue_options(options)
			expect(options[':use-scope']).to eq 'sc'
		end

		it 'does not add a scope if given none' do
			tag = stub_tag
			options = {}
			tag.add_vue_options options
			expect(options).not_to have_key 'use-scope'
		end

		it 'adds :show-always if given :show_always' do
			options = { 'show_always' => true }
			tag = stub_tag
			tag.add_vue_options(options)
			expect(options[':show-always']).to be true
		end
	end
end
