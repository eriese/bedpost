Rake::Task['webpacker:compile'].enhance ['i18n:js:export']
Rake::Task['assets:precompile'].enhance ['webpacker:compile']
