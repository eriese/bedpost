class StiTest
	include Mongoid::Document
	field :tested_on, type: Date

	embedded_in :user_profile
	embeds_many :results, class_name: 'StiTestResult'
	accepts_nested_attributes_for :results, allow_destroy: true
	index({ tested_on: -1 }, unique: true)
	validates :tested_on, presence: true, uniqueness: true

	PARAM_FORMAT = '%b-%d-%Y'.freeze

	def to_param
		self.class.date_to_param(tested_on)
	end

	def tested_on=(val)
		dt = self.class.param_to_date(val)
		super(dt)
	end

	def self.with_date(date)
		date = date.is_a?(Date) ? date : param_to_date(date)
		where(tested_on: date).first
	end

	def self.date_to_param(date)
		I18n.localize(date, format: PARAM_FORMAT)
	end

	def self.param_to_date(param)
		param.is_a?(String) ? Date.parse(param) : param
	end
end
