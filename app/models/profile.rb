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
#

class Profile < ActiveRecord::Base
  attr_accessible :anus_name, :email, :genital_name, :name, :password_digest, :pronoun, :password, :password_confirmation, :uid
  has_many :partnerships, foreign_key: "user_id"
  has_many :partners, :through => :partnerships, :source => :partner
  has_many :sti_tests, foreign_key: "user_id"
  has_many :encounters, foreign_key: "user_id"
  has_secure_password
end
