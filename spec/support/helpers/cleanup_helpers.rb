module CleanupHelpers
	def cleanup(*objs)
		objs.each {|o| o.destroy if o && o.persisted?}
	end
end
