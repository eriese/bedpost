class Profile < ActiveRecord::Base
  attr_accessible :anus_name, :email, :genital_name, :name, :password_digest, :pronoun
  has_many :partners, class_name: "Partnership",foreign_key: "user_id"
end
