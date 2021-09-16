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

	def clean_mailer_jobs
		Delayed::Backend::Mongoid::Job.where(:queue.in => ['devise_notifications', 'mailers']).destroy_all
	end

	def print_db_remnants(include_dummies = true)
		db_has = false
		Mongoid.default_client.collections.each do |c|
			if c.count > 0 && (include_dummies || !collection_is_only_dummy?(c))
				db_has = true
				puts "#{c.namespace}: #{c.count}".light_magenta.bold
			end
		end
		db_has
	end

	def collection_is_only_dummy?(collection)
		return false if !['pronouns', 'profiles'].include?(collection.name) || collection.count > 1

		check_name = collection.name == 'pronouns' ? Pronoun.first.subject : Profile.first.name
		check_name == 'dummy'
	end
end
