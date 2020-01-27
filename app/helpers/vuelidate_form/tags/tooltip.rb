module VuelidateForm
	module Tags
		# A tooltip tag that uses tippy to describe the input for the given method
		class Tooltip < ActionView::Helpers::Tags::Base
			# the text content of the tooltip
			def content(options = {})
				key = options.delete('key')
				t_key = key.blank? || key == true ? @method_name : key
				translation = ActionView::Helpers::Tags::Translator.new(@object, @object_name, t_key, scope: 'helpers.tooltip').translate
				translation.present? ? translation.html_safe : ''
			end

			# add the options for a vue tooltip component
			def add_vue_options(options = {})
				slot_scope = options.delete 'slot_scope'
				options[':use-scope'] = slot_scope if slot_scope.present?

				add_default_name_and_id(options)

				show_always = options.delete('show_always')
				options[':show-always'] = show_always if show_always
				options[':interactive'] = options.delete('interactive')
			end

			# render the tooltip
			def render
				options = @options.stringify_keys
				add_vue_options(options)
				content_tag(:tooltip, content(options), options)
			end

			def add_default_name_and_id(options = {})
				return unless generate_ids?
				index = name_and_id_index(options)
				parent_id = tag_id(index)
				options['id'] = "#{parent_id}-tooltip-content"

				# use the tag_id to get the id of the target
				options['to-selector'] = options.fetch('to') { "##{parent_id}" }

				# add the namespace
				return unless (namespace = options.delete('namespace'))

				options['to-selector'] = "#{namespace}_#{options['to-selector']}"
			end
		end
	end
end
