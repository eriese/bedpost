class Profile
  include Mongoid::Document
  include Mongoid::Timestamps::Short

  field :name, type: String
  field :pr, as: :pronoun, type: String
  field :a_n, as: :anus_name, type: String
  field :e_n, as: :external_name, type: String
  field :i_n, as: :internal_name, type: String

  validates_presence_of :name, :pronoun, :anus_name, :external_name

  def has_internal?
  	self.internal_name != nil
  end
end
