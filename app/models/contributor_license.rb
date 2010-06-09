class ContributorLicense < ActiveRecord::Base
  unloadable

  attr_accessor :acceptance
  
  belongs_to :user

  validates_inclusion_of :state, :in => %w(pending accepted), :allow_blank => false, :allow_nil => false
  validates_format_of :acceptance, :with => /I agree/i, :on => :create

  def after_initialize
    self.state = 'pending' unless self.state.present?
  end

  def accept!
    return self if state == 'accepted'
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
