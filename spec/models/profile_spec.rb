require 'spec_helper'

describe Profile do
  before :each do
    @u1 = Profile.create({anus_name: "ass", email: "email", genital_name: "genitals", password: "pass", password_confirmation: "pass", pronoun: "he", name: "User 1"})
    @u2 = Profile.create({anus_name: "ass", email: "email", genital_name: "genitals", password: "pass", password_confirmation: "pass", pronoun: "ze", name: "User 2"})
  end
  context "profile has partners, can't see who has it as partner" do
    before :each do
      @p1 = @u1.partnerships.create({partner_id: @u2.id, exclusivity: 1, familiarity: 1})
    end
    it "can have another profile as a partner" do
      expect(@u1.partners).to include(@u2)
    end
    it "can't see who has it as a partner" do
      expect(@u2.partners).to_not include(@u1)
    end
  end
end
