require 'rails_helper'

RSpec.describe Profile, type: :model do
  it "has a name" do
  	prof = build_stubbed(:profile)
  	expect(prof.name).to_not be_nil
  end

  it "requires a name" do
  	prof = build_stubbed(:profile, name: nil)
  	expect(prof.valid?).to be false

    details = prof.errors.details[:name]
    expect(details).to include({error: :blank})
  end

  it "requires a pronoun" do
  	prof = build_stubbed(:profile, pronoun: nil)
  	expect(prof.valid?).to be false

    details = prof.errors.details[:pronoun]
    expect(details).to include({error: :blank})
  end

  it "requires a name for the anus" do
  	prof = build_stubbed(:profile, anus_name: nil)
  	expect(prof.valid?).to be_falsy

    details = prof.errors.details[:anus_name]
    expect(details).to include({error: :blank})
  end

  it "requires a name for the external genitals" do
  	prof = build_stubbed(:profile, external_name: nil)
  	expect(prof.valid?).to be false

    details = prof.errors.details[:external_name]
    expect(details).to include({error: :blank})
  end

  it "does not require a name for the internal genitals" do
  	prof = build_stubbed(:no_internal)
  	expect(prof.valid?).to be true
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
