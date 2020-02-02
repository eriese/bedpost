if Rails.env.development?
	require 'colorize'
	require 'yaml'

	namespace :push do
		desc 'run tests to make sure the current code will pass CI build'
		task :test do
			puts 'running checks'.blue.bold
			errors = []
			{
				RSpec: 'SKIP_PENDING=true rspec',
				Jest: 'yarn test --verbose=false',
				Brakeman: 'bundle exec brakeman -q',
				'Bundle Audit' => 'bundle audit --update'
			}.each do |key, command|
				sh command do |ok, response|
					unless ok
						puts "stopping because of #{key} failure: ", response
						errors << {key: response}
						break
					end
				end
			end

			if errors.empty?
				puts 'All checks passed. You are ready to push!'.green.bold
			else
				puts 'Please fix the following errors before pushing:'.red.bold
				errors.each { |k, e| puts "#{k}: #{e}".to_s.red }
			end
		end
	end
end
