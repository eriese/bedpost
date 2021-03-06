source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.7'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.3'
# Use Puma as the app server
gem 'puma', '~> 3.12'
# Use SCSS for stylesheets
gem 'sassc-rails'
gem 'normalize-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.x'
# put javascript variables directly from the controller
gem 'gon'
# add internationalization to javascript
gem "i18n-js"
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

gem 'mongoid', '~> 7.0'
gem 'mongoid_rails_migrations'
gem 'bson_ext'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

gem 'devise'
gem 'mailjet'
gem "aws-ses", "~> 0.6.0", :require => 'aws/ses'

gem 'daemons'
gem 'delayed_job'
gem 'delayed_job_mongoid'

gem 'rack-cors'
gem 'http'
#handle env vars

gem 'route_downcaser'
gem 'colorize'

gem 'pry'
gem 'pry-stack_explorer'

group :development, :test do
	gem 'rspec-rails', '~> 3.8'
	gem "rails-controller-testing"
	# Call 'byebug' anywhere in the code to stop execution and get a debugger console
	gem 'pry-remote'
	gem 'pry-byebug'
	gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
	# Access an interactive console on exception pages or by calling 'console' anywhere in the code.
	gem 'web-console', '>= 3.3.0'
	gem 'listen', '>= 3.0.5', '< 3.2'
	gem 'guard'
	gem 'guard-rspec'
	gem 'guard-livereload', '~> 2.5', require: false
	gem "rack-livereload"
	gem 'guard-webpack'
	gem 'guard-shell'
	# gem 'guard-rails', require: false
	# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
	gem 'spring'
	gem 'spring-watcher-listen', '~> 2.0.0'
	gem 'spring-commands-rspec'
	gem 'rack-mini-profiler', require: false
	gem 'foreman'

	gem 'brakeman'
	gem 'bundler-audit'

	#linting
	gem 'rubocop'
	gem 'rubocop-thread_safety'
	gem 'rubocop-rspec'
	gem 'rubocop-rails'
	gem 'rubocop-performance'
end

group :test do
	gem 'factory_bot_rails'
	# Adds support for Capybara system testing and selenium driver
	gem 'capybara', '>= 2.15'
	gem 'launchy'
	# gem 'selenium-webdriver'
	# Easy installation and use of chromedriver to run system tests with Chrome
	gem 'simplecov', require: false
	gem 'codecov', require: false

	gem 'fakeredis'
end

group :production do
	gem 'hiredis'
	gem 'redis'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
