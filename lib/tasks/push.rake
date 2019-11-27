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

			bundle_ruby = Bundler::Definition.build('Gemfile', nil, {}).ruby_version.versions[0]
			travis_ruby = YAML.load_file('.travis.yml')['rvm'][0]
			installed_ruby = `ruby -v`
			ruby_v = File.open('.ruby-version').readlines[0].chomp

			if ruby_v == travis_ruby && ruby_v == bundle_ruby && installed_ruby.include?(ruby_v)
				puts 'consistent ruby versions'.green
			else
				puts 'inconsistent ruby versions'
				puts "ruby -v: #{installed_ruby}"
				puts "Gemfile: #{bundle_ruby}"
				puts ".ruby-version: #{ruby_v}"
				puts ".travis.yml: #{travis_ruby}"
				errors << { 'ruby install' => 'inconsistent ruby versions' }
			end

			if errors.empty?
				puts 'All checks passed. You are ready to push!'.blue.bold
			else
				puts 'Please fix the following errors before pushing:'.red.bold
				errors.each { |k, e| puts "#{k}: #{e}".to_s.red }
			end
		end
	end
end
