desc 'shortcut to run foreman start -p 3000'
task :foreman, [:port] do
	port = args[:port] || 3000
	sh "foreman start -p #{port}"
end

namespace :workflow do
	desc 'make sure yarn and bundle packages are up to date'
	task :update do
		sh 'yarn install --check-files'
		sh 'bundle install'
	end
end
