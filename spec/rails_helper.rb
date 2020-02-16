# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

# Add additional requires below this line. Rails is not loaded until this point!
require 'rspec/rails'
# require 'capybara/rails'
require 'capybara/rspec'
require 'fakeredis/rspec'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

RSpec.configure do |config|
	# RSpec Rails can automatically mix in different behaviours to your tests
	# based on their file location, for example enabling you to call `get` and
	# `post` in specs under `spec/controllers`.
	#
	# You can disable this behaviour by removing the line below, and instead
	# explicitly tag your specs with their type, e.g.:
	#
	#     RSpec.describe UsersController, :type => :controller do
	#       # ...
	#     end
	#
	# The different available types are documented in the features, such as in
	# https://relishapp.com/rspec/rspec-rails/docs
	config.infer_spec_type_from_file_location!

	# Filter lines from Rails gems in backtraces.
	config.filter_rails_from_backtrace!
	# arbitrary gems may also be filtered via:
	# config.filter_gems_from_backtrace("gem name")

	# include factory bot
	config.include FactoryBot::Syntax::Methods
	config.include FeatureHelpers, type: :feature
	config.include ActionView::Helpers::SanitizeHelper, type: :feature
	config.include Devise::Test::ControllerHelpers, type: :controller
	config.include Devise::Test::ControllerHelpers, type: :view
	config.include Devise::Test::IntegrationHelpers, type: :feature

	include UserProfileHelpers
	include CleanupHelpers

	Capybara.run_server = false

	config.before :suite do
		FakeRedis.enable
	end

	#clear the dummy user after all the tests are run
	config.after :suite do
		work_jobs
		UserProfileHelpers.clear_all_dummies
		puts
		puts
		db_has = print_db_remnants

		puts "Database is clean".green.bold unless db_has
	end

	config.around :each, :run_job_immediately do |example|
		orig_worker_state = Delayed::Worker.delay_jobs
		Delayed::Worker.delay_jobs = false
		example.run
		Delayed::Worker.delay_jobs = orig_worker_state
	end

	config.after :each do
		clean_mailer_jobs
		work_jobs
		# print_db_remnants false
	end
end
