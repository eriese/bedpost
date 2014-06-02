class Encounter < ActiveRecord::Base
  attr_accessible :fluid, :notes, :partner_id, :self_risk, :took_place, :user_id, :contacts_attributes
  belongs_to :partner
  has_many :contacts
  validates :partner_id, :presence => true
  accepts_nested_attributes_for :contacts, reject_if: lambda {|contact| contact[:partner_instrument].blank?}
  def no_barrier
    self.contacts.where(barriers: false)
  end
  def with_barrier
    self.contacts.where(barriers: true)
  end
  def risk
    @risk = 0
    @risk += self.no_barrier.length * 2
    @risk += self.with_barrier.length / 2
    @risk += 4 if self.fluid
    @risk *= partner.risk
    @risk /= 10
    @risk += self.self_risk
    @risk /= 2
    return @risk
  end
  def has_contact?(user_instrument, partner_instrument)
    self.contacts.include?([user_inst: user_instrument, partner_inst: partner_instrument, barriers: true]) || self.contacts.include?([user_inst: user_instrument, partner_inst: partner_instrument, barriers: false])
  end
  def has_barriers?(user_instrument, partner_instrument)
    self.contacts.include?([user_inst: user_instrument, partner_inst: partner_instrument, barriers: true])
  end
end
