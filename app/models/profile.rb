class Profile
  include Mongoid::Document
  include Mongoid::Timestamps::Short

  field :name, type: String
  field :pr, as: :pronoun, type: String
  field :a_n, as: :anus_name, type: String
  field :e_n, as: :external_name, type: String
  field :i_n, as: :internal_name, type: String

  def has_internal?
  	@internal_name != nil
  end
end
