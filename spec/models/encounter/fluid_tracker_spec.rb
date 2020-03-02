require 'rails_helper'

RSpec.describe Encounter::FluidTracker, type: :model do
	describe '#track_before' do
		context 'with a clean instrument' do
			it 'empties all fluids on the instrument' do
				inst = build_stubbed(:contact_instrument, can_clean: true)
				contact = double("EncounterContact", {barriers: [:clean_subject]})

				tracker = Encounter::FluidTracker.new(inst, :user)
				tracker.own_on_instrument << :hand
				tracker.other_on_instrument << :genitals
				expect(tracker.own_on_instrument).to include(:hand)

				tracker.track_before(contact, true)
				expect(tracker.own_on_instrument).to be_empty
				expect(tracker.other_on_instrument).to be_empty
			end

			it 'leaves any present fluids on the barrier' do
				inst = build_stubbed(:contact_instrument, can_clean: true)
				contact = double("EncounterContact", {barriers: [:clean_subject]})

				tracker = Encounter::FluidTracker.new(inst, :user)
				tracker.other_on_barrier << :genitals

				tracker.track_before(contact, true)
				expect(tracker.other_on_barrier).to include(:genitals)
			end
		end

		context 'with a fresh barrier' do
			it 'empties all fluids on the barrier' do
				inst = build_stubbed(:contact_instrument, can_clean: true)
				contact = double("EncounterContact", {barriers: [:fresh]})

				tracker = Encounter::FluidTracker.new(inst, :user)
				tracker.own_on_barrier << :hand
				expect(tracker.own_on_barrier).to include(:hand)

				tracker.track_before(contact, true)
				expect(tracker.own_on_barrier).to be_empty
			end

			it 'leaves any present fluids on the instrument' do
				inst = build_stubbed(:contact_instrument, can_clean: true)
				contact = double("EncounterContact", {barriers: [:fresh]})

				tracker = Encounter::FluidTracker.new(inst, :user)
				tracker.other_on_instrument << :genitals

				tracker.track_before(contact, true)
				expect(tracker.other_on_instrument).to include(:genitals)
			end
		end
	end

	describe '#track_after' do
		context 'with an other instrument with no fluids' do
			it 'does nothing' do
				inst = build_stubbed(:contact_instrument, has_fluids: false)
				contact = double("EncounterContact")

				tracker = Encounter::FluidTracker.new(inst, :user)
				tracker.track_after(contact, inst)

				expect(tracker.own_on_barrier).to be_empty
				expect(tracker.other_on_barrier).to be_empty
				expect(tracker.own_on_instrument).to be_empty
				expect(tracker.other_on_instrument).to be_empty
			end
		end

		context 'with a barrier' do
			context 'in a self-contact' do
				it 'adds the other instrument alias name to @own_on_barrier' do
					inst = build_stubbed(:contact_instrument, has_fluids: true, _id: :genitals, alias_of_id: :external_genitals)
					contact = double("EncounterContact", {has_barrier?: true, is_self?: true})

					tracker = Encounter::FluidTracker.new(inst, :user)
					tracker.track_after(contact, inst)

					expect(tracker.own_on_barrier).to include(inst.alias_name)
				end
			end

			context 'in a partner contact' do
				it 'adds the other instrument id to @other_on_barrier' do
					inst = build_stubbed(:contact_instrument, has_fluids: true, _id: :genitals)
					contact = double("EncounterContact", {has_barrier?: true, is_self?: false})

					tracker = Encounter::FluidTracker.new(inst, :user)
					tracker.track_after(contact, inst)

					expect(tracker.other_on_barrier).to include(inst._id)
				end
			end
		end

		context 'without a barrier' do
			context 'in a self-contact' do
				it 'adds the other instrument id to @own_on_instrument' do
					inst = build_stubbed(:contact_instrument, has_fluids: true, _id: :genitals)
					contact = double("EncounterContact", {has_barrier?: false, is_self?: true})

					tracker = Encounter::FluidTracker.new(inst, :user)
					tracker.track_after(contact, inst)

					expect(tracker.own_on_instrument).to include(inst._id)
				end
			end

			context 'in a partner contact' do
				it 'adds the other instrument id to @other_on_instrument' do
					inst = build_stubbed(:contact_instrument, has_fluids: true, _id: :genitals)
					contact = double("EncounterContact", {has_barrier?: false, is_self?: false})

					tracker = Encounter::FluidTracker.new(inst, :user)
					tracker.track_after(contact, inst)

					expect(tracker.other_on_instrument).to include(inst._id)
				end
			end
		end
	end

	describe '#fluids_present?' do
		context 'a self contact' do
			it 'returns whether the fluids from the other person are on the instrument' do
				inst = build_stubbed(:contact_instrument, has_fluids: true, _id: :genitals)
				contact1 = double("EncounterContact", {has_barrier?: true, is_self?: true})
				contact2 = double("EncounterContact", {has_barrier?: false, is_self?: true})

				tracker = Encounter::FluidTracker.new(inst, :partner)
				tracker.other_on_barrier << :anus

				expect(tracker.fluids_present?(contact1)).to be true
				expect(tracker.fluids_present?(contact2)).to be false
			end
		end

		context 'a partner contact' do
			it 'returns whether fluids from the person the instrument belongs to are on the instrument' do
				inst = build_stubbed(:contact_instrument, has_fluids: true, _id: :genitals)
				contact1 = double("EncounterContact", {has_barrier?: true, is_self?: false})
				contact2 = double("EncounterContact", {has_barrier?: false, is_self?: false})

				tracker = Encounter::FluidTracker.new(inst, :partner)
				tracker.own_on_barrier << :anus

				expect(tracker.fluids_present?(contact1)).to be true
				expect(tracker.fluids_present?(contact2)).to be false
			end
		end
	end
end
