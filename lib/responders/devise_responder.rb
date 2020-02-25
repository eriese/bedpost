require './lib/responders/uniqueness_responder.rb'

class DeviseResponder < UniquenessResponder
	def to_json
		if !has_errors? && options[:location].present?
			redirect_to options[:location]
		else
			to_format
		end
	end

	def default_action
		@action = :new_beta if ENV['IS_BETA'] && post?
		super
	end
end
