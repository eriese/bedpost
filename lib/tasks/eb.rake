namespace :eb do
	desc 'set the master key environment variable and then deploy'
	task :deploy, [:environment_name] do |t, args|
		environment_name = args[:environment_name]
		sh "eb use #{environment_name}" if environment_name.present?

		puts 'Checking env variables...'
		env_vars = `eb printenv #{environment_name}`
		begin
			key_file = File.open('config/master.key')
			key = key_file.readlines[0].chomp
			if env_vars.include?("RAILS_MASTER_KEY = #{key}")
				puts 'Skipping setting RAILS_MASTER_KEY because it is already set'
			else
				puts 'Setting RAILS_MASTER_KEY'
				`eb setenv RAILS_MASTER_KEY=#{key}`
			end
		rescue Errno::ENOENT
			puts 'Skipping setting RAILS_MASTER_KEY because no key file was found'
		end

		branch_name = `git symbolic-ref --quiet --short HEAD`.chomp
		branch_name = '' if branch_name == 'master'
		commit_name = `git rev-parse --short HEAD`.chomp

		unless environment_name
			envs = `eb list`.split("\n")
			environment_name = envs.find { |n| n.start_with? '*' }[2..-1]
		end

		build_name = "#{environment_name}:#{branch_name}#{branch_name.empty? ? '' : '.'}#{commit_name}"
		puts "Deploying build #{build_name} to #{environment_name}"
		sh "eb deploy -l #{build_name}"
	end
end
