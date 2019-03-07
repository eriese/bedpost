class Profile
  include Mongoid::Document
  include Mongoid::Timestamps::Short
  include NormalizeBlankValues
  include DeAliasFields

  field :name, type: String
  field :a_n, as: :anus_name, type: String
  field :e_n, as: :external_name, type: String
  field :i_n, as: :internal_name, type: String

  belongs_to :pronoun, optional: true
  has_and_belongs_to_many :partnered_to, class_name: "Profile", inverse_of: nil, after_remove: :delete_if_empty

  validates_presence_of :name
  #only run this validation on the base class
  validates_presence_of :pronoun, :anus_name, :external_name, :if => :is_base?

  def has_internal?
  	self.internal_name.present?
  end

  def is_base?
  	self.instance_of?(Profile)
  end

  def add_partnered_to(partner_profile)
    self.partnered_to.push(partner_profile)
  end

  def remove_partnered_to(partner_profile)
    self.partnered_to.delete(partner_profile)
  end

  def self.add_partnered_to(profile_id, partner_profile)
    prof = find(profile_id).add_partnered_to(partner_profile)
  end

  def self.remove_partnered_to(profile_id, partner_profile)
    prof = find(profile_id).remove_partnered_to(partner_profile)
  rescue Mongoid::Errors::DocumentNotFound
    Rails.logger.warn "Tried to remove a partnership from a profile that had already been deleted" unless Rails.env == 'test'
  end

  private
  def delete_if_empty(removed = nil)
    if self.is_base? && self.partnered_to.count == 0
      self.destroy
    end
  end
end
