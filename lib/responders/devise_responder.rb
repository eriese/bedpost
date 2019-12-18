require './lib/responders/uniqueness_responder.rb'

class DeviseResponder < UniquenessResponder
	def to_json
		if !has_errors? && options[:location].present?
			redirect_to options[:location]
		else
			to_format
		end
	end
end
