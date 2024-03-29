class Contact::BarrierType
	attr_reader :key, :conditions, :exclude

	def initialize(hsh)
		@key = hsh[:key]
		@exclude = hsh[:exclude]
		@encounter_conditions = hsh[:encounter_conditions]
		@contact_conditions = hsh[:contact_conditions]
	end

	def mongoize
		@key
	end

	TYPES = Hash[[{
		key: :fresh,
		exclude: [:old, :clean_subject, :clean_object]
	}, {
		key: :old,
		exclude: [:fresh, :clean_subject, :clean_object],
		encounter_conditions: [:has_barrier]
	}, {
		key: :clean_subject,
		contact_conditions: [:subject_instrument_id],
		exclude: [:old, :fresh]
	}, {
		key: :clean_object,
		contact_conditions: [:object_instrument_id],
		exclude: [:old, :fresh]
	}].map { |r|
															res = Contact::BarrierType.new(r)
															[res.key, res]
														} ]

	class BarrierArray < Array
		def mongoize(object)
			object.map { |el| el.intern }
		end

		class << self
			def demongoize(object)
				object
			end

			def mongoize(object)
				case object
				when Array
					object.map { |el| el.intern }
				else object
				end
			end

			def evolve(object)
				object
			end
		end
	end
end
