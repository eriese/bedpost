class StiTest
	include Mongoid::Document
	field :tested_on, type: DateTime
	field :positive, type: Boolean, default: false

	belongs_to :tested_for, class_name: 'Diagnosis'
	index({ tested_on: -1, tested_for: 1 }, unique: true)
	validates_presence_of :tested_on, :positive

	PARAM_FORMAT = '%b-%d-%Y'.freeze

	def to_param
		self.class.date_to_param(tested_on)
	end

	def tested_on=(val)
		dt = val.is_a?(String) ? DateTime.parse(val) : val
		super(dt.beginning_of_day)
	end

	def self.date_to_param(dt)
		I18n.localize(dt, format: PARAM_FORMAT)
	end
end
