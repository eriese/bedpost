require 'colorize'

namespace :push do
	desc 'run tests to make sure the current code will pass CI build'
	task :test do
		puts "running checks".blue.bold
		all_clear = true
		{
			RSpec: 'SKIP_PENDING=true rspec',
			Jest: 'yarn test --verbose=false',
			Brakeman: 'bundle exec brakeman -q',
			'Bundle Audit' => 'bundle audit --update'
		}.each do |key, command|
			sh %{#{command}} do |ok, response|
				if !ok
					puts "stopping because of #{key} failure: ", response
					all_clear = false
					break
				end
			end
		end

		if all_clear
			puts "All checks passed. You are ready to push!".colorize(color: :blue, mode: :bold)
		else
			puts "Please fix these errors before pushing".colorize(color: :red, mode: :bold)
		end
	end
end
