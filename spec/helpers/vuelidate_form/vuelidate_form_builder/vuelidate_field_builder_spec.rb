require 'rails_helper'

RSpec.describe VuelidateForm::VuelidateFormBuilder::VuelidateFieldBuilder, type: :helper do

	def stub_form_builder(validators: [], submission_error: {})
		@obj_name = "object_name"
		obj_class = class_double("FormObjectClass", validators_on: validators)
		f_obj = double("FormObject", class: obj_class, name: "My Name")

		helper.flash[:submission_error] = submission_error

		@f_builder = VuelidateForm::VuelidateFormBuilder.new(@obj_name, f_obj, helper, {})
	end

	def stub_builder(options: {}, validators: [], submission_error: {}, attribute: :name)
		@attr = attribute
		stub_form_builder(validators: validators, submission_error: submission_error)
		VuelidateForm::VuelidateFormBuilder::VuelidateFieldBuilder.new(attribute, options, @f_builder, helper)
	end

	describe '#add_ARIA' do
		context 'aria-describedby' do

			def get_desc
				@builder.instance_variable_get(:@external_options)[:"aria-describedby"]
			end

			it 'adds the id of the error field to the description if the form should validate' do
				@builder = stub_builder validators: [""]

				expect(@builder.instance_variable_get(:@validate)).to eq true
				expect(get_desc).to eq "#{@attr}-error"
			end

			it 'adds the id of the tooltip of another field if given the symbol of that field' do
				desc = :tool
				@builder = stub_builder options: {:"aria-describedby" => desc}

				expect(get_desc).to eq "#{desc}-tooltip-content"
			end

			it 'leaves any given string in the description' do
				desc = "other-text"
				@builder = stub_builder options: {:"aria-describedby" => desc}

				expect(get_desc).to eq desc
			end

			it 'adds the id of the tooltip if the field has a tooltip' do
				@builder = stub_builder options: {tooltip: true}

				expect(get_desc).to eq "#{@attr}-tooltip-content"
			end

			it 'adds the id of the tooltip and the errors if both tooltip and validate are true' do
				@builder = stub_builder options: {tooltip: true, validate: true}

				@builder.send(:add_ARIA)

				desc_result = get_desc
				expect(desc_result).to include("#{@attr}-tooltip-content")
				expect(desc_result).to include("#{@attr}-error")
			end

			it 'adds the id of the tooltip and the tooltip of the other field and the errors if all are required' do
				desc = :tool
				@builder = stub_builder options: {tooltip: true, validate: true, :"aria-describedby" => desc}

				@builder.send(:add_ARIA)

				desc_result = get_desc
				expect(desc_result).to include("#{@attr}-tooltip-content")
				expect(desc_result).to include("#{@attr}-error")
				expect(desc_result).to include("#{desc}-tooltip-content")
			end

			it 'always puts the error first' do
				desc = "other-text"

				@builder = stub_builder options: {tooltip: true, validate: true, :"aria-describedby" => desc}

				@builder.send(:add_ARIA)

				desc_result = get_desc
				expect(desc_result).to include("#{@attr}-tooltip-content")
				expect(desc_result).to include(desc)
				expect(desc_result).to start_with("#{@attr}-error")
			end
		end

		context "aria-invalid" do
			def get_invalid(vue)
				sym = vue ? :":aria-invalid" : :"aria-invalid"
				@builder.instance_variable_get(:@external_options)[sym]
			end

			it 'does not add invalid attributes if the field should not validate' do
				@builder = stub_builder

				@builder.send(:add_ARIA)

				expect(@builder.instance_variable_get(:@validate)).to eq false
				expect(get_invalid(true)).to be_nil
				expect(get_invalid(false)).to be_nil
			end

			it 'adds an invalid attribute that vue/vuelidate can change dynamically' do
				@builder = stub_builder options: {validate: true}

				@builder.send(:add_ARIA)

				expect(get_invalid(true)).to eq "slot.vField.$invalid && slot.vField.$dirty"
			end

			it 'adds a fallback invalid attribute based off of the flash submission errors' do
				atr = :name
				sub_errors = {}
				sub_errors[atr] = [""]
				@builder = stub_builder attribute: atr, options: {validate: true}, submission_error: sub_errors

				@builder.send(:add_ARIA)

				expect(get_invalid(false)).to be true
			end

			it 'the fallback invalid attribute is false is there are no submission errors for the field' do
				@builder = stub_builder options: {validate: true}

				@builder.send(:add_ARIA)

				expect(get_invalid(false)).to be false
			end
		end

		context "aria-required" do
			def get_required(vue)
				sym = vue ? :":aria-required" : :"aria-required"
				@builder.instance_variable_get(:@external_options)[sym]
			end

			it 'does not add required attributes if the field should not validate' do
				@builder = stub_builder

				@builder.send(:add_ARIA)

				expect(@builder.instance_variable_get(:@validate)).to eq false
				expect(get_required(true)).to be_nil
				expect(get_required(false)).to be_nil
			end

			it 'adds a required attribute that vue/vuelidate can change dynamically' do
				@builder = stub_builder options: {validate: true}

				@builder.send(:add_ARIA)

				expect(get_required(true)).to eq "slot.vField.blank !== undefined"
			end

			it 'adds a fallback required attribute based off of the validators on the attribute' do
				validators = [double("PresenceValidator", kind_of?: true)]
				@builder = stub_builder validators: validators

				@builder.send(:add_ARIA)

				expect(get_required(false)).to be true
			end

			it 'the fallback required attribute is false is there are no presence validators for the field' do
				@builder = stub_builder options: {validate: true}

				@builder.send(:add_ARIA)

				expect(get_required(false)).to be false
			end
		end
	end

	describe '#add_v_model' do
		it 'sets the v-model option' do
			builder = stub_builder
			builder.send(:add_v_model)
			expect(builder.instance_variable_get(:@external_options)[:"v-model"]).to eq "formData.#{@obj_name}.#{@attr}"
		end

		it 'sets the ref option to have the same name as the attribute' do
			builder = stub_builder
			builder.send(:add_v_model)
			expect(builder.instance_variable_get(:@external_options)[:ref]).to eq @attr
		end

		it 'sets the blur option if the field validates' do
			builder = stub_builder options: {validate: true}
			builder.send(:add_v_model)
			expect(builder.instance_variable_get(:@external_options)[:@blur]).to eq "slot.vField.$touch"
		end

		it 'does not set the blur option if the field does not validate' do
			builder = stub_builder
			builder.send(:add_v_model)
			expect(builder.instance_variable_get(:@external_options)[:@blue]).to be nil
		end
	end

	describe "#do_setup" do
		it 'adds the aria attributes' do
			builder = stub_builder
			allow(builder).to receive(:add_ARIA) {nil}

			builder.send(:do_setup)
			expect(builder).to have_received(:add_ARIA)
		end

		it 'add the v-model attributes' do
			builder = stub_builder
			allow(builder).to receive(:add_v_model) {nil}

			builder.send(:do_setup)
			expect(builder).to have_received(:add_v_model)
		end

		it 'does not add its attribute to the validation list on the form builder if it does not validate' do
			builder = stub_builder
			builder.send(:do_setup)

			expect(@f_builder.validations).to be_nil
		end
	end

	describe '#field_label' do
		it 'returns a label' do
			builder = stub_builder

			result = builder.send(:field_label)

			expect(result).to eq "<label id=\"#{@attr}-label\" for=\"#{@obj_name}_#{@attr}\">#{@attr.to_s.humanize}</label>"
		end

		it 'uses a symbol passed to the label option as the label attribute' do
			label_opt = :other_key
			builder = stub_builder options: {label: label_opt}

			result = builder.send(:field_label)

			expect(result).to eq "<label id=\"#{label_opt}-label\" for=\"#{@obj_name}_#{label_opt}\">#{label_opt.to_s.humanize}</label>"
		end

		it 'uses the options passed to the label option for the label creation' do
			label_opt = {other_option: "yes"}
			builder = stub_builder options: {label: label_opt}

			result = builder.send(:field_label)
			expected = @f_builder.label(@attr, label_opt.merge({id: "#{@attr}-label"}))
			expect(result).to eq expected
		end

		it 'uses the key passed to the label option as the label attribute and all other options passed as label options' do
			label_key = :other_key

			label_opt = {other_option: "yes", key: label_key}
			builder = stub_builder options: {label: label_opt}

			result = builder.send(:field_label)

			expected_opts = label_opt.except(:key).merge({id: "#{label_key}-label"})
			expected = @f_builder.label(label_key, expected_opts)
			expect(result).to eq expected
		end

		it 'does not end up with a key attribute on the label' do
			label_key = :other_key

			label_opt = {other_option: "yes", key: label_key}
			builder = stub_builder options: {label: label_opt}

			result = builder.send(:field_label)

			expect(result).to_not include("key=\"")
		end

		it 'returns a blank string if the label option is false' do
			builder = stub_builder options: {label: false}
			result = builder.send(:field_label)
			expect(result).to be_blank
		end
	end

	describe '#process_options' do
		it 'is called during initialization' do
			allow_any_instance_of(VuelidateForm::VuelidateFormBuilder::VuelidateFieldBuilder).to receive(:process_options).and_call_original
			builder = stub_builder
			expect(builder).to have_received(:process_options)
		end

		# it 'sets the field class' do
		# 	builder = stub_builder
		# 	expect(builder.instance_variable_get(:@options)[:class]).to eq "field"
		# end

		# it 'sets the field class based on the field_class option' do
		# 	cls = "fieldy"
		# 	builder = stub_builder options: {field_class: cls}

		# 	result_class = builder.instance_variable_get(:@options)[:class]
		# 	expect(result_class).to include "field"
		# 	expect(result_class).to include cls
		# end

		context "@validate" do
			context 'it uses the validate option over all else' do
				it 'validate set to true causes validation' do
					builder = stub_builder options: {validate: true}
					expect(builder.instance_variable_get(:@validate)).to be true
				end
				it 'validate set to false causes no validation even if the attribute has validators' do
					builder = stub_builder options: {validate: false}, validators: ["val"]
					expect(builder.instance_variable_get(:@validate)).to be false
				end
			end

			context 'it uses the presence of validators in the absence of a validate option' do
				it 'no validators on the attribute means no validation' do
					builder = stub_builder
					expect(builder.instance_variable_get(:@validate)).to be false
				end

				it 'validators on the attribute cause validation' do
					builder = stub_builder validators: ["val"]
					expect(builder.instance_variable_get(:@validate)).to be true
				end
			end
		end
	end

	describe '#field_inner' do
		it 'adds the label' do
			builder = stub_builder
			builder.send :do_setup
			result = builder.field_inner

			expected_label = @f_builder.label(@attr, {id: "#{@attr}-label"})
			expect(result).to include(expected_label)
		end

		it 'adds the tooltip if the tooltip is called for' do
			builder = stub_builder options: {tooltip: true}
			builder.send :do_setup
			result = builder.field_inner

			expected_tooltip = @f_builder.tooltip(@attr)
			expect(result).to include(expected_tooltip)
		end

		it 'adds the given block at the end' do
			builder = stub_builder
			builder.send :do_setup

			additional = "additional"
			result = builder.field_inner {additional}

			expect(result).to end_with(additional)
		end

		it 'adds the given block at the beginning if the before_label option is true' do
			builder = stub_builder options: {before_label: true}
			builder.send :do_setup

			additional = "additional"
			result = builder.field_inner {additional}

			expect(result).to start_with(additional)
		end
	end

	describe '#field' do
		it 'adds its attribute to the validation list on the form builder if it validates' do
			stub_form_builder
			@attr = :name
			@f_builder.text_field(@attr, {validate: true})
			expect(@f_builder.validations).to include @attr
		end

		it 'puts the content of the after-method inside the error wrapper' do
			stub_form_builder
			@attr = :name
			result = @f_builder.password_field(@attr, {show_toggle: true, validate: true})

			toggle_output = @f_builder.password_toggle
			expect(result).to_not end_with(toggle_output)
		end

		context '@external_options' do
			it 'a block given to the field does not still have any of the options meant for the field' do
				allow_any_instance_of(VuelidateForm::VuelidateFormBuilder).to receive(:text_field).and_call_original
				opts = {before_label: true}
				stub_form_builder
				@attr = :name
				@f_builder.text_field(@attr, opts)

				builder = VuelidateForm::VuelidateFormBuilder::VuelidateFieldBuilder.new(@attr, opts, @f_builder, helper)

				expected_opts = builder.instance_variable_get(:@external_options)
				expect(@f_builder).to have_received(:text_field).with(@attr, expected_opts)
			end
		end
	end
end
