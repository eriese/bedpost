module DirtyTrackingEmbedded
	def self.included(base)
		base.const_get(:ClassMethods).prepend(ClassMethods)
	end

	module ClassMethods
		# override the embedding methods to also make dirty-tracking
		def embeds_many(name, options = {}, &block)
			define_method "clear_unsaved_#{name}" do
				send(name).each { |o| remove_child(o) unless o.persisted? }
			end
			super
		end

		def embeds_one(name, options = {}, &block)
			define_method "clear_unsaved_#{name}" do
				dirty = send(name)
				remove_child(dirty) unless dirty.persisted?
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
