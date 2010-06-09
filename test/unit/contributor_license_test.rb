require File.dirname(__FILE__) + '/../test_helper'

class ContributorLicenseTest < ActiveSupport::TestCase
  should_belong_to :user

  should "initialize state to 'pending'" do
    assert_equal "pending", ContributorLicense.new.state
  end

  should_allow_values_for(:state, "pending", "accepted")
  should_not_allow_values_for(:state, "", nil, "garbarge", "long" * 1000, 1000)
  
end
