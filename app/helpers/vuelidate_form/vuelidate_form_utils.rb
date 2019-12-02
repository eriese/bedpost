module VuelidateForm; module VuelidateFormUtils
	# Map the validators to a format that can be used by the form
	# @param validators [Array] an array of validators
	# @param object [Object] the object that the validators will validate
	def self.map_validators_for_form(validators, object)
		is_new = false
		validators.each_with_object([]) do |v, ary|
			# foreign keys can't be checked by the front end
			next if v.kind == :foreign_key

			# if there's an on condition for the validator
			if on_cond = v.options[:on]
				# get whether it's new
				is_new ||= object.respond_to?(:new_record?) && object.new_record?
				# don't add it if the condition is false
				next unless (is_new && on_cond == :create) || (!is_new && on_cond == :update)
			end

			# if there's an if condition on the validator
			if if_cond = v.options[:if]
				# don't add if it's false
				next unless object.send(if_cond)
			end

			# add it to the array
			ary << [v.kind, v.options]
		end
	end

	protected
	def add_to_class(args, class_name="", key_name=:class, add_to_front=false)
		new_name = args[key_name].nil? ? "" : args[key_name]
		if add_to_front
			new_name = class_name + " " + new_name
		else
			new_name << " " << class_name
		end
		args[key_name] = new_name.strip
	end
end;end
