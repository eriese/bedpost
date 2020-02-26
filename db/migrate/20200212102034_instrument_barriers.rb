class InstrumentBarriers < Mongoid::Migration
	def self.up
		inst_barriers = {
			hand: {
				subject_barriers: [{ type: :glove }]
			},
			external_genitals: {
				subject_barriers: [{ type: :condom }],
				object_barriers: [{ type: :condom, conditions: [:can_penetrate], with_insts: [:mouth] }]
			},
			internal_genitals: {
				object_barriers: [{ type: :condom }]
			},
			anus: {
				object_barriers: [{ type: :condom }]
			},
			mouth: {
				subject_barriers: [{ type: :dam }]
			},
			toy: {
				subject_barriers: [{ type: :condom }, { type: :glove }]
			}
		}

		inst_barriers.each do |inst_id, barrier_hash|
			inst = Contact::Instrument.find(inst_id)
			inst.update(barrier_hash)
			inst.aliases.update(barrier_hash)
		end
	end

	def self.down
		Contact::Instrument.update(subject_barriers: nil, object_barriers: nil)
	end
end
