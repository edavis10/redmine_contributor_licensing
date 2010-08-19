class ContributorLicense < ActiveRecord::Base
  unloadable

  attr_accessor :acceptance
  attr_accessible :acceptance # Block state and user

  acts_as_attachable
  
  belongs_to :user
  belongs_to :accepted_by, :class_name => 'User'

  validates_inclusion_of :state, :in => %w(pending accepted), :allow_blank => false, :allow_nil => false

  before_destroy :block_deleting_accepted

  named_scope :assigned_to_users, :conditions => ["#{ContributorLicense.table_name}.user_id IS NOT NULL"]
  named_scope :sorted_by_login, :order => "#{User.table_name}.login ASC", :include => :user
  
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
  
  def self.missing_users
    User.active.all(:include => :contributor_license,
                    :conditions => ["#{ContributorLicense.table_name}.id is NULL"]).sort
  end

  def self.signers_for_project(project)
    project.users.all(:include => :contributor_license,
                      :conditions => ["#{ContributorLicense.table_name}.id is NOT NULL AND #{ContributorLicense.table_name}.state = ?", "accepted"])
  end
  
  if Rails.env.test?
    generator_for :acceptance => 'I agree'
  end
  
end
