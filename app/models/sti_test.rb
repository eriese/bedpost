# == Schema Information
#
# Table name: sti_tests
#
#  id         :integer          not null, primary key
#  date_taken :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class StiTest < ActiveRecord::Base
  attr_accessible :date_taken, :infections_attributes
  has_many :infections
  belongs_to :user, class_name: "Profile", foreign_key: "user_id"
  accepts_nested_attributes_for :infections, reject_if: lambda {|infection| infection[:positive].blank? || (infection[:positive] == "_destroy" && infection[:id].nil?) }, :allow_destroy => true
  def diseases
    self.infections.map do |infection|
      infection.disease
    end
  end
  def prep_for_update
    (DISEASES.map { |disease| disease[:name] } - self.diseases).each do |dis|
      self.infections.new(disease: dis, positive: nil)
    end
  end
end
