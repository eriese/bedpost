# == Schema Information
#
# Table name: profiles
#
#  id              :integer          not null, primary key
#  email           :string(255)
#  name            :string(255)
#  password_digest :string(255)
#  pronoun         :string(255)
#  anus_name       :string(255)
#  genital_name    :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  uid             :string(255)
#  min_window      :integer          default(6)
#

class Profile < ActiveRecord::Base
  attr_accessible :anus_name, :email, :genital_name, :name, :password_digest, :pronoun, :password, :password_confirmation, :uid, :min_window
  has_many :partnerships, foreign_key: "user_id"
  has_many :partners, :through => :partnerships, :source => :partner
  has_many :sti_tests, foreign_key: "user_id"
  has_many :encounters, foreign_key: "user_id"
  validates_uniqueness_of :uid, message: "That partnering ID is unavailable. Please try a different one."
  has_secure_password

  def risk_window(disease_name)
    case_test_ids = self.sti_tests.map { |tst| tst.id }
    cases = Infection.where({disease: disease_name, id: case_test_ids}).sort_by {|infection| infection.sti_test.date_taken}
    cases.reverse!
    if cases.any?
      if cases.find{|infection| infection.positive == false}
        last_neg = cases.find{|infection| infection.positive == false}
      else
        last_neg = cases.last
      end
      for_time = last_neg.sti_test.date_taken.to_s.split("-")
      t = Time.mktime(for_time[0], for_time[1], for_time[2])
      window = t - DISEASES.find{|disease| disease[:name] == disease_name}[:gestation_max] * (60 * 60 * 24 * 7)
      return window
    end
  end
  def overdue?(disease_name)
    if self.risk_window(disease_name)
      return self.risk_window(disease_name) < Time.now - self.min_window * (60 * 60 * 24 * 7)
    else
      return true
    end
  end
  def overdue_tests
    overdue_list = []
    DISEASES.each do |disease|
      overdue_list << disease[:name] if self.overdue?(disease[:name])
    end
    return overdue_list
  end
end
