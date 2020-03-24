require 'colorize'

namespace :eb do
	PROD_ENV = 'bedpost-prod-1'.freeze
	STAGING_ENV = 'bepost-staging-2'.freeze

	def deploy_to_environment(args, unsafe_allowed=false)
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

		branch_name = current_branch_name
		environment_name ||= current_env_name
		return unless unsafe_allowed || safe_env?({environment_name: environment_name})

		commit_name = `git rev-parse --short HEAD`.chomp

		build_name = "#{environment_name}:#{branch_name}#{branch_name.empty? ? '' : '.'}#{commit_name}"
		puts "Deploying build #{build_name} to #{environment_name}"
		build_name
	end

	def current_env_name
		envs = `eb list`.split("\n")
		envs.find { |n| n.start_with? '*' }.sub('* ', '')
	end

	def safe_env?(args)
		environment_name = args[:environment_name] || current_env_name
		if environment_name == PROD_ENV
			puts "You're trying to deploy to production. If you really want to do that, you have to use rake eb:deploy_prod"
			false
		else
			true
		end
	end

	def current_branch_name
		branch_name = `git symbolic-ref --quiet --short HEAD`.chomp
		branch_name == 'master' ? '' : branch_name
	end

	def deploy(build_name)
		sh "eb deploy -l #{build_name}"
	end

	desc 'set the elastic beanstalk environment to production'
	task :use_prod do
		sh "eb use #{PROD_ENV}"
	end

	desc 'set the elastic beanstalk environment to staging'
	task :use_staging do
		sh "eb use #{STAGING_ENV}"
	end

	desc 'set the master key environment variable and then deploy'
	task :deploy, [:environment_name] do |t, args|
		build_name = deploy_to_environment args
		deploy(build_name)
	end

	task :deploy_staged, [:environment_name] do |t, args|
		build_name = deploy_to_environment args
		sh "eb deploy -l #{build_name}-staged --staged"
	end

	desc 'deploy to production and reset the used environment after'
	task :deploy_prod do
		current_branch = current_branch_name
		if current_branch.present?
			print "You're trying to deploy a branch that isn't master to production. Are you sure that's right? Type the current branch name to continue".blue.bold
			unless STDIN.gets.chomp == current_branch
				puts "No match. Exiting.".bold
				next
			end
		end

		orig_env = current_env_name
		puts 'switching to production environment'
		sh "eb use #{PROD_ENV}"
		build_name = deploy_to_environment({}, true)
		deploy(build_name)
		if orig_env == "#{PROD_ENV}"
			puts "Your current beanstalk environment is production. Be Careful!".light_white.bold.on_magenta
		else
			puts "switching back to #{orig_env} environment"
			sh "eb use #{orig_env}"
		end
	end
end
