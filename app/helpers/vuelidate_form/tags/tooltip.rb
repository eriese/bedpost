module VuelidateForm
	module Tags
		class Tooltip < ActionView::Helpers::Tags::Base
			def initialize(object_name, method_name, template_object, options = {})
				super
				@key = options.delete(:key)
			end

			def content
				t_key = @key == true ? @method_name : @key
				ActionView::Helpers::Tags::Translator.new(@object, @object_name, t_key, scope: 'helpers.tooltip').translate
			end

			def render
				options = @options.stringify_keys
				options['class'] = 'tooltip' + (options['class'] || '')
				options['class'] += '--show-always' if options.delete('show_always')
				add_default_name_and_id(options)
				options.reverse_merge!({
					'animation' => 'shift-away',
					'append-to' => 'parent',
					':arrow' => true,
					'boundary' => 'viewport',
					':delay' => '[200, 0]',
					':flip' => true,
					'placement' => 'bottom',
				})

				slot_scope = options.delete 'slot_scope'
				if slot_scope.present?
					options['trigger'] = 'manual'
					options[':hide-on-click'] = false
					options[':visible'] = "#{slot_scope}.focused || #{slot_scope}.hovered"
					options[':a11y'] = false
				end

				content_tag(:tooltip, content, options)
			end

			def add_default_name_and_id(options)
				return unless generate_ids?
				index = name_and_id_index(options)
				options['to-selector'] = options.fetch('to') { "##{tag_id(index)}" }
				options['to-selector'] = options['to-selector'] ? "#{namespace}_#{options['to-selector']}" : namespace if namespace = options.delete('namespace')
			end
		end
	end
end
