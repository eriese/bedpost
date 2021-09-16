require 'rspec/expectations'

RSpec::Matchers.define :have_validation_error_for do |field, err|
	match do |actual|
		details = get_details(actual, field)
		return details.any? if err.nil?

		err_detail = details.find { |det| det[:error] == err }
		err_detail != nil
	end

	failure_message do |actual|
		err.nil? ?
						"expected that there would be any errors on :#{field}"
						: "expected that errors on :#{field} (#{get_details(actual, field)}) would include #{err}"
	end

	failure_message_when_negated do |actual|
		details = get_details(actual, field)
		err.nil? ?
						"expected that there would be no errors on :#{field}, but got #{details}"
						: "expected that errors on :#{field} (#{details}) would not include #{err}"
	end

	def get_details(obj, field)
		obj.errors.details[field]
	end
end
