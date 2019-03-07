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

  describe '#delete_if_empty' do
    after :each do
      cleanup(@prof, @partner)
    end

    it 'deletes itself if it has no relationships and is not a UserProfile' do
      @prof = create(:profile)
      @prof.send :delete_if_empty
      expect(@prof.persisted?).to be false
    end

    it 'does not delete itself if it has relationships' do
      @prof = create(:profile)
      @prof.partnered_to << dummy_user
      @prof.send :delete_if_empty
      expect(@prof.persisted?).to be true
    end

    it 'runs after a relationship is removed' do
      @prof = create(:profile)
      allow(@prof).to receive(:delete_if_empty).and_call_original
      @prof.partnered_to.push(dummy_user)
      @prof.partnered_to.delete(dummy_user)

      expect(@prof).to have_received :delete_if_empty
      expect(@prof.persisted?).to be false
    end

    it 'runs after a relationship is removed and does not delete if there are still others' do
      @prof = create(:profile)
      allow(@prof).to receive(:delete_if_empty).and_call_original
      @prof.partnered_to.push(dummy_user)
      @partner = create(:user_profile)
      @prof.partnered_to.push(@partner)
      @prof.partnered_to.delete(dummy_user)

      expect(@prof).to have_received :delete_if_empty
      expect(@prof.persisted?).to be true
    end
  end

  describe '#add_partnered_to' do
    after :each do
      cleanup(@prof, @partner)
    end

    it 'adds a profile to the partnered_to list' do
      @prof = create(:user_profile)
      @partner = create(:profile)

      @prof.add_partnered_to(@partner)
      @prof.reload

      expect(@prof.partnered_to_ids).to include(@partner.id)
      expect(@prof.partnered_to).to_not be_empty
    end
  end

  describe '#remove_partnered_to' do
    after :each do
      cleanup(@prof, @partner)
    end

    it 'removes the profile from the partnered_to list' do
      @prof = create(:profile)
      @partner = create(:user_profile)

      @prof.add_partnered_to(@partner)
      @prof.remove_partnered_to(@partner)

      expect(@prof.partnered_to_ids).to_not include(@partner.id)
    end

    it 'calls #delete_if_empty' do
      @prof = create(:profile)
      @partner = create(:user_profile)

      @prof.add_partnered_to(@partner)
      allow(@prof).to receive(:delete_if_empty).and_call_original
      @prof.remove_partnered_to(@partner)

      expect(@prof).to have_received :delete_if_empty
    end
  end
end
