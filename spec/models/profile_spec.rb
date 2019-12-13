require 'rails_helper'

RSpec.describe Profile, type: :model do
	it "requires a name" do
		prof = build_stubbed(:profile, name: nil)
		expect(prof).to_not be_valid
		expect(prof).to have_validation_error_for(:name, :blank)
	end

	it "requires a pronoun" do
		prof = build_stubbed(:profile, pronoun: nil)
		expect(prof).to_not be_valid
		expect(prof).to have_validation_error_for(:pronoun, :blank)
	end

	it "requires a name for the anus" do
		prof = build_stubbed(:profile, anus_name: nil)
		expect(prof).to_not be_valid
		expect(prof).to have_validation_error_for(:anus_name, :blank)
	end

	it "requires a name for the external genitals" do
		prof = build_stubbed(:profile, external_name: nil)
		expect(prof).to_not be_valid
		expect(prof).to have_validation_error_for(:external_name, :blank)
	end

	it "does not require a name for the internal genitals" do
		prof = build_stubbed(:no_internal)
		expect(prof).to be_valid
		expect(prof).to_not have_validation_error_for(:internal_name, :blank)
	end

	describe "#has_internal?" do
		it "regards unnamed internal genitals as absent" do
			prof = build_stubbed(:no_internal)
			has_internal = prof.has_internal?
			expect(has_internal).to be false
		end

		it "regards named internal genitals as present" do
			prof = build_stubbed(:with_internal)
			has_internal = prof.has_internal?
			expect(has_internal).to be true
		end
	end
end
