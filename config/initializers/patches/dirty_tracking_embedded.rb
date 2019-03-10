module DirtyTrackingEmbedded
	def self.included(base)
		base.const_get(:ClassMethods).prepend(ClassMethods)
	end

	module ClassMethods
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
end

module Mongoid
	module Association
		module Macros
			include DirtyTrackingEmbedded
		end
	end
end
