module DirtyTrackingEmbedded
	extend ActiveSupport::Concern

	class_methods do
		# override the embedding methods to also make dirty-tracking
		def embeds_many(name, options= {}, &block)
			define_method "clear_unsaved_#{name}" do
				new_list = send(name).select(&:persisted?)
				send(name.to_s + "=", new_list)
			end
			super
		end

		def embeds_one(name, options={}, &block)
			define_method "clear_unsaved_#{name}" do
				send(name.to_s + "=", nil) unless send(name).persisted?
			end
			super
		end
	end

	private
	# def clear_embedded_of_type(list_name, false_case=false, &block)
	# 	orig_list = self.send(list_name)
	# 	of_type = orig_list.select(&block)
	# 	new_list = false_case ? of_type : orig_list - of_type
	# 	self.send(list_name.to_s + "=", new_list)
	# end

	# def clear_embedded_not_of_type(list_name, &block)
	# 	clear_embedded_of_type(list_name, true, &block)
	# end
end
