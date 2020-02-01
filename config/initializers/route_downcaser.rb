RouteDowncaser.configuration do |config|
	config.redirect = true

	config.exclude_patterns = [
		/assets\//i,
		/public\/(packs|javascripts)\//i,
		/some\/important\/path/i
	]
end
