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

	def work_jobs(options = {})
		orig_worker_state = Delayed::Worker.delay_jobs
		Delayed::Worker.delay_jobs = false
		result = Delayed::Worker.new(options).work_off
		Delayed::Worker.delay_jobs = orig_worker_state
		result
	end

	def clean_devise_jobs
		Delayed::Backend::Mongoid::Job.where(queue: 'devise_notifications').destroy_all
	end
end
