module VuelidateForm
	module Tags
		class Label < ActionView::Helpers::Tags::Label
			class LabelBuilder < ActionView::Helpers::Tags::Label::LabelBuilder
				def initialize(template_object, object_name, method_name, object, tag_value, options)
					super(template_object, object_name, method_name, object, tag_value)
					@options = options
				end

				def translation
					method_and_value = @options.has_key?('key') ? @options.delete('key') : @method_name
					method_and_value = @tag_value.present? ? "#{method_and_value}.#{@tag_value}" : method_and_value

					content ||= ActionView::Helpers::Tags::Translator
																	.new(object, @object_name, method_and_value, scope: 'helpers.label')
																	.translate
					content ||= @method_name.humanize

					content
				end
			end

			def render(&block)
				options = @options.stringify_keys
				tag_value = options.delete('value')
				name_and_id = options.dup

				if name_and_id['for']
					name_and_id['id'] = name_and_id['for']
				else
					name_and_id.delete('id')
				end

				add_default_name_and_id_for_value(tag_value, name_and_id)
				options.delete('index')
				options.delete('namespace')
				options['id'] = "#{name_and_id['id']}-label"
				options['for'] = name_and_id['id'] unless options.key?('for')

				builder = LabelBuilder.new(@template_object, @object_name, @method_name, @object, tag_value, options)

				content = if block_given?
															@template_object.capture(builder, &block)
														elsif @content.present?
															@content.to_s
														else
															render_component(builder)
														end

				options.delete('key')

				label_tag(name_and_id['id'], content, options)
			end

			private def render_component(builder)
				content = builder.translation
				content = I18n.t('helpers.required', **{ content: content }) if (@options['required'])
				content.html_safe
			end
		end
	end
end
