class ContributorLicense < ActiveRecord::Base
  unloadable
  
  belongs_to :user

  validates_inclusion_of :state, :in => %w(pending accepted), :allow_blank => false, :allow_nil => false

  def after_initialize
    self.state = 'pending' unless self.state.present?
  end
end
