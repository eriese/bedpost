class Pronoun
  include Mongoid::Document

  field :subject
  field :object
  field :possessive
  field :obj_possessive
  field :reflexive

  has_many :profiles

  def display
  	"#{subject}/#{object}/#{obj_possessive}"
  end

end
