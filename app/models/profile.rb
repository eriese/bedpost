class Profile
  include Mongoid::Document
  include Mongoid::Timestamps::Short
  include NormalizeBlankValues

  field :name, type: String
  field :a_n, as: :anus_name, type: String
  field :e_n, as: :external_name, type: String
  field :i_n, as: :internal_name, type: String

  belongs_to :pronoun, optional: true

  validates_presence_of :name
  #only run this validation on the base class
  validates_presence_of :pronoun, :anus_name, :external_name, :if => :is_base?

  def has_internal?
  	self.internal_name.present?
  end

  private
  def is_base?
  	self.instance_of?(Profile)
  end
end
