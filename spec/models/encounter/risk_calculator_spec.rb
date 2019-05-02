require 'rails_helper'

RSpec.describe Encounter::RiskCalculator, type: :model do
  before :each do
  	allow(Diagnosis).to receive(:as_map) {Hash.new {|hsh, key| hsh[key] = build_stubbed(:diagnosis, {name: key})}}
  	allow(PossibleContact).to receive(:as_map) {Hash.new { |hsh, key| hsh[key] = build_stubbed(:possible_contact, {subject_instrument_id: :external_genitals, object_instrument_id: :internal_genitals, _id: key}) }}
  	allow(Contact::Instrument).to receive(:as_map) {Hash.new { |hsh, key| hsh[key] = build_stubbed(:contact_instrument, {name: key}) }}
  	allow(Diagnosis::TransmissionRisk).to receive(:grouped_by) {Hash.new { |hsh, key| hsh[key] = [build_stubbed(:diagnosis_transmission_risk, {possible_contact_id: key})] }}
  end

  it 'creates a map showing the highest transmission risk of the encounter for each diagnosis' do
  	calc = Encounter::RiskCalculator.new(Encounter.new)
  	risks = calc.instance_variable_get(:@risks)

  	contact1 = build_stubbed(:encounter_contact, {possible_contact_id: "contact1"})
  	calc.track_contact(contact1)
  	risk1 = risks[contact1.possible_contact_id][0]

  	expect(calc.risk_map[risk1.diagnosis_id]).to eq risk1.risk_to_subject

  	contact2 = build_stubbed(:encounter_contact, {possible_contact_id: "contact2"})
  	calc.track_contact(contact2)
  	risk2 = risks[contact2.possible_contact_id][0]

  	contact3 = build_stubbed(:encounter_contact, {possible_contact_id: "contact3"})
  	calc.track_contact(contact3)
  	risk3 = risks[contact3.possible_contact_id][0]

  	expected = [risk1.risk_to_subject, risk2.risk_to_subject, risk3.risk_to_subject].max
  	expect(calc.risk_map[risk1.diagnosis_id]).to eq expected
  end
end
