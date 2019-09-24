namespace :assets do
end

Rake::Task['assets:precompile'].enhance ['i18n:js:export']
