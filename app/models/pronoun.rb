class Pronoun
  include Mongoid::Document
  include StaticResource

  field :subject
  field :object
  field :possessive
  field :obj_possessive
  field :reflexive

  has_many :profiles

  def display
  	"#{subject}/#{object}/#{obj_possessive}"
  end

  def self.list
    all.to_ary
  end
end
