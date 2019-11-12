# A concern to hold methods needed by WhosControllers
module WhosController
	extend ActiveSupport::Concern

	# Did the user navigate to this page from the dashboard?
	def from_dash?
		request.referer && URI(request.referer).path == root_path
	end
end
