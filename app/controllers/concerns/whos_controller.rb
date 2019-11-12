module WhosController
	extend ActiveSupport::Concern

	def from_dash?
		request.referer && URI(request.referer).path == root_path
	end
end
