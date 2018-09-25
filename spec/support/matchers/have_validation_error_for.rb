require 'rspec/expectations'

RSpec::Matchers.define :have_validation_error_for do |field, err|
  match do |actual|
    details = get_details(actual, field)
    err_detail = details.find {|det| det[:error] == err}
    err_detail != nil
  end
  failure_message do |actual|
  	details = get_details(actual, field)
    "expected that errors on #{field} (#{details}) would be include #{err}"
  end
  failure_message_when_negated do |actual|
  	details = get_details(actual, field)
    "expected that errors on #{field} (#{details}) would not be include #{err}"
  end

  def get_details(obj, field)
  	obj.errors.details[field]
  end
end
