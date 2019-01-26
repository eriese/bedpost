alphabet = Array("a".."z")
FactoryBot.define do
  factory :pronoun do
  	sequence(:subject) {|n| "#{alphabet[n]}e"}
  	sequence(:object) {|n| "#{alphabet[n]}er"}
  	sequence(:possessive) {|n| "#{alphabet[n]}er"}
  	sequence(:obj_possessive) {|n| "#{alphabet[n]}ers"}
  	sequence(:reflexive) {|n| "#{alphabet[n]}erself"}
  end
end
