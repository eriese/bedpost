class Tour
	include Mongoid::Document
	include StaticResource
	field :page_name, type: String
	field :fte_only, type: Boolean, default: false
	embeds_many :tour_nodes

	index({ page_name: 1, fte_only: -1 }, unique: true)

	STRIP_IDS_REGEX = /[^\/]+\d+[^\/]+/

	# search by page and cache
	def self.by_page(page_name, fte_only = false)
		page_name = page_name.gsub(STRIP_IDS_REGEX, '')
		args = { page_name: page_name }
		key = "page_name:#{page_name},fte_only:#{fte_only}"
		cached(key) do
			if fte_only
				where(args).order(fte_only: :desc).first
			else
				args[:fte_only] = false
				find_by(args)
			end
		end
	end

	# search and cache a page without throwing an error if it doesn't exist
	def self.by_page!(page_name, fte_only = false)
		by_page(page_name, fte_only)
	rescue Mongoid::Errors::DocumentNotFound
		false
	end
end
