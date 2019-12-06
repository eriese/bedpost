module VuelidateForm
	module Tags
		# A tooltip tag that uses tippy to describe the input for the given method
		class Tooltip < ActionView::Helpers::Tags::Base
			DEFAULT_OPTIONS = {
				'animation' => 'shift-away',
				'append-to' => 'parent',
				':arrow' => true,
				'boundary' => 'viewport',
				':delay' => '[200, 0]',
				':flip' => true,
				'placement' => 'bottom'
			}.freeze

			THEME = 'light'.freeze

			# the text content of the tooltip
			def content(options)
				key = options.delete('key')
				t_key = key == true ? @method_name : key
				ActionView::Helpers::Tags::Translator.new(@object, @object_name, t_key, scope: 'helpers.tooltip').translate
			end

			# generate the html markup for a tooltip that always shows
			def always_shown_tooltip(options = {})
				options.delete 'slot_scope'

				theme = options.delete 'theme'
				options['class'] = options.fetch('class') { '' }
				options['class'] += " tippy-tooltip #{theme}-theme"
				options['x-placement'] = 'bottom'
				options['id'] = options.fetch('id') { "#{tag_id}-tooltip-content" }

				@template_object.content_tag(:aside, class: 'tippy-popper', 'x-placement' => 'bottom') do
					@template_object.content_tag(:div, options) do
						content_tag(:div, '', class: 'tippy-arrow') +
							content_tag(:div, content(options), class: 'tippy-content')
					end
				end
			end

			# add the options for a tooltip that uses properties from the slot to control its state
			def add_slot_scope(options)
				slot_scope = options.delete 'slot_scope'
				return if slot_scope.blank?

				# we're manually setting when it should open
				options['trigger'] = 'manual'
				# we're manually setting when it should close
				options[':hide-on-click'] = false
				# open if the input is hovered or focused
				options[':visible'] = "#{slot_scope}.focused || #{slot_scope}.hovered"
				# don't add tabindex=0 to the target element because we are taking care of that
				options[':a11y'] = false
			end

			# render the tooltip
			def render
				options = @options.stringify_keys
				# add the theme
				options['theme'] ||= THEME

				# if it's always supposed to show, render that
				return always_shown_tooltip(options) if options.delete('show_always')

				# set up the options
				add_default_name_and_id(options)
				add_slot_scope(options)
				options.reverse_merge! DEFAULT_OPTIONS

				content_tag(:tooltip, content(options), options)
			end

			def add_default_name_and_id(options)
				return unless generate_ids?

				# use the tag_id to get the id of the target
				index = name_and_id_index(options)
				options['to-selector'] = options.fetch('to') { "##{tag_id(index)}" }

				# add the namespace
				return unless (namespace = options.delete('namespace'))

				options['to-selector'] = "#{namespace}_#{options['to-selector']}"
			end
		end
	end
end
