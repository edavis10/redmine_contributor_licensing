class ContributorLicense < ActiveRecord::Base
  unloadable

  attr_accessor :acceptance
  attr_accessible :acceptance # Block state and user
  
  belongs_to :user

  validates_inclusion_of :state, :in => %w(pending accepted), :allow_blank => false, :allow_nil => false

  def after_initialize
    self.state = 'pending' unless self.state.present?
  end

  def validate_acceptance
    if acceptance.present? && acceptance.match(/I agree/i)
      true
    else
      errors.add(:acceptance, l(:field_acceptance))
      false
    end
  end

  def accept!
    return self if state == 'accepted'
    return false unless validate_acceptance
    
    self.state = 'accepted'
    self.accepted_at = Time.now
    self.save
  end

  def accepted?
    state == "accepted"
  end
  alias :accepted_contributor_license? :accepted?

  if Rails.env.test?
    generator_for :acceptance => 'I agree'
  end
  
end
