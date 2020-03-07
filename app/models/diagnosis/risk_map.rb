class Diagnosis::RiskMap < Hash
	def initialize(default_val = Diagnosis::TransmissionRisk::NO_RISK)
		super(default_val)
	end

	def store(key,val)
		val_level = risk_value(val)
		return if key?(key) && risk_level(key) > val_level

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
end
