class StiTest
	include Mongoid::Document
	field :tested_for, type: Symbol
	field :tested_on, type: DateTime
	field :positive, type: Boolean, default: false

	index({ tested_on: -1, tested_for: 1 }, unique: true)

	PARAM_FORMAT = '%b-%d-%Y'.freeze

	def to_param
		I18n.localize(tested_on, format: PARAM_FORMAT)
	end

	def tested_on=(val)
		dt = val.is_a?(String) ? DateTime.parse(val) : val
		super(dt.beginning_of_day)
	end
end
