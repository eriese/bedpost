module CleanupHelpers
	def cleanup(*objs, debug: false)
		objs.each do |o|
			next unless o
			if !(o.destroy || o.reload.destroy)
				puts ("unable to delete #{o.id}: #{o} because #{o.errors.messages}")
			elsif debug
				puts("successfully deleted #{o.id}: #{o}")
			end
		end
	end
end
