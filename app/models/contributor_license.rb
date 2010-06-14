class ContributorLicense < ActiveRecord::Base
  unloadable

  attr_accessor :acceptance
  attr_accessible :acceptance # Block state and user

  acts_as_attachable
  
  belongs_to :user
  belongs_to :accepted_by, :class_name => 'User'

  validates_inclusion_of :state, :in => %w(pending accepted), :allow_blank => false, :allow_nil => false

  before_destroy :block_deleting_accepted
  
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

  def accept!(accepting_user = User.current)
    return self if state == 'accepted'
    return false unless validate_acceptance
    
    self.state = 'accepted'
    self.accepted_at = Time.now
    self.accepted_by = accepting_user
    self.save
  end

  def accepted?
    state == "accepted"
  end
  alias :accepted_contributor_license? :accepted?

  def block_deleting_accepted
    if accepted?
      errors.add(:base, l(:contributor_licensing_error_can_not_delete_accepted))
      return false
    else
      return true
    end
  end

  def to_s
    "Contributor License"
  end
  
  if Rails.env.test?
    generator_for :acceptance => 'I agree'
  end
  
end
