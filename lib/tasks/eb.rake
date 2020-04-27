require 'colorize'

namespace :eb do
	PROD_ENV = 'bedpost-prod-1'.freeze
	STAGING_ENV = 'bedpost-staging-2'.freeze
	CACHE_ID = 'bedpost-staging'.freeze
	AUTO_SCALER = 'awseb-e-4tnmiiqqbj-stack-AWSEBAutoScalingGroup-1C0XG7MV16JT2'.freeze

	def set_env_vars(environment_name, cache_url=nil)
		puts 'Checking env variables...'
		env_vars = `eb printenv #{environment_name}`
		keys_to_set = []
		begin
			key_file = File.open('config/master.key')
			key = key_file.readlines[0].chomp
			if env_vars.include?("RAILS_MASTER_KEY = #{key}")
				puts 'Skipping setting RAILS_MASTER_KEY because it is already set'
			else
				puts 'Adding RAILS_MASTER_KEY to variables'
				keys_to_set << "RAILS_MASTER_KEY=#{key}"
			end
		rescue Errno::ENOENT
			puts 'Skipping setting RAILS_MASTER_KEY because no key file was found'
		end
		if cache_url.nil?
			if env_vars.include? "REDIS_URL = #{cache_url}"
				puts 'Skipping setting REDIS_URL because it is already set correctly'
			else
				puts 'Setting REDIS_URL'
				keys_to_set << "REDIS_URL=#{cache_url}"
			end
		end
		`eb setenv #{keys_to_set.join(' ')}` unless keys_to_set.empty?
	end

	def deploy_to_environment(args, unsafe_allowed=false, cache_url=nil)
		environment_name = args[:environment_name]
		sh "eb use #{environment_name}" if environment_name.present?

		set_env_vars(environment_name, cache_url)

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

	def create_staging_cache
		puts 'checking staging cache status'
		cache_desc = `aws elasticache describe-replication-groups --replication-group-id #{CACHE_ID} 2>&1`
		if !cache_desc.include?('An error occurred')
			status = JSON.parse(cache_desc).dig('ReplicationGroups', 0, 'Status')
			puts status.match('deleting').nil? ? 'cache is set up' : 'cache is deleting. You\'ll need to put one back up when it\'s finished'.bold.light_white.on_magenta
			return
		end
		puts 'setting up a cache for staging'
		# make the cache
		`aws elasticache create-replication-group \
		--replication-group-id #{CACHE_ID} \
		--replication-group-description "bedpost staging cache" \
		--preferred-cache-cluster-a-zs us-east-1a \
		--cache-node-type cache.t2.micro \
		--engine redis \
		--cache-subnet-group-name bedpost-staging-redis-subnet \
		--security-group-ids sg-0c2dfeeb9daefa2cd \
		--at-rest-encryption-enabled`
	end

	def use_env(env_name)
		sh "eb use #{env_name}"
	end

	def staging_is_paused?
		scaler_desc = `aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name #{AUTO_SCALER}`
		JSON.parse(scaler_desc).dig('AutoScalingGroups', 0, 'DesiredCapacity') == 0
	end

	desc 'set the elastic beanstalk environment to production'
	task :use_prod do
		use_env(PROD_ENV)
	end

	desc 'set the elastic beanstalk environment to staging'
	task :use_staging do
		use_env(STAGING_ENV)
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

	desc 'deploy to staging, adding a cache if needed'
	task :deploy_staging do
		create_staging_cache
		use_env(STAGING_ENV)
		if staging_is_paused?
			puts 'Staging is paused. un-pausing staging'
			`eb scale 1`
		else
			puts 'Staging is already running. skipping to deployment'
		end
		Rake::Task['eb:deploy'].invoke
	end

	task :check_staging do
		puts staging_is_paused? ? 'Staging is paused' : 'Staging is running'
	end

	desc 'pause all resources for the staging environment'
	task :pause_staging do
		use_env(STAGING_ENV)
		puts 'shutting down staging cache'
		`aws elasticache delete-replication-group --replication-group-id #{CACHE_ID}`
		puts 'scaling down staging load balancer'
		sh 'eb scale 0'
		puts 'finished pausing staging resources'
	end

	desc 'un-pause all resources for the staging environment'
	task :unpause_staging do
		use_env(STAGING_ENV)
		create_staging_cache
		puts 'scaling up staging load balancer'
		sh 'eb scale 1'
	end
end
