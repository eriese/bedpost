class Diagnosis::RiskMap < Hash
	def initialize(default_val = Diagnosis::TransmissionRisk::NO_RISK)
		super(default_val)
	end

	def store(key, val)
		return unless choose_higher_val(val, risk(key)) == val

		super(key, val)
	end

	def []=(key, val)
		store(key, val)
	end

	def risk(key)
		self[key]
	end

	def risk_value(val)
		val.is_a?(Array) ? val[0] : val
	end

	def risk_level(key)
		risk_value(risk(key))
	end

	def risk_caveats(key)
		return nil unless risk(key).is_a?(Array)

		risk(key)[1]
	end

	def merge(other)
		super(other) { |_key, val1, val2| choose_higher_val(val1, val2) }
	end

	private

	def choose_higher_val(val1, val2)
		return (val2.nil? ? nil : val2) if val1.nil?
		return val1 if val2.nil?

		val1_val = risk_value(val1)
		val2_val = risk_value(val2)

		return (val1_val > val2_val ? val1 : val2) unless val1_val == val2_val

		val1_is_array = val1.is_a? Array
		val2_is_array = val2.is_a? Array

		if val1_is_array && val2_is_array
			merged = val1[1] + val2[1]
			[val1_val, merged.sort]
		elsif val1_is_array
			val1
		else
			val2
		end
	end
end
