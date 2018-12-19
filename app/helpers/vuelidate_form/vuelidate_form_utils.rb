module VuelidateForm
	module VuelidateFormUtils
		def add_to_class(args, class_name="", key_name=:class, add_to_front=false)
			new_name = args[key_name].nil? ? "" : args[key_name]
			if add_to_front
				new_name = class_name + " " + new_name
			else
				new_name << " " << class_name
			end
			args[key_name] = new_name.strip
		end
	end
end
