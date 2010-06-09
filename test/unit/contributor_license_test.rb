require File.dirname(__FILE__) + '/../test_helper'

class ContributorLicenseTest < ActiveSupport::TestCase
  should_belong_to :user

  should "initialize state to 'pending'" do
    assert_equal "pending", ContributorLicense.new.state
  end

  should_allow_values_for(:state, "pending", "accepted")
  should_not_allow_values_for(:state, "", nil, "garbarge", "long" * 1000, 1000)

  context "accept!" do
    setup do
      @license = ContributorLicense.generate!
    end
    
    should "update the state to 'accepted'" do
      @license.accept!
      assert_equal 'accepted', @license.reload.state
    end
    
    should "timestamp the 'accepted_at' field" do
      assert_equal nil, @license.accepted_at

      @license.accept!

      assert @license.reload.accepted_at
    end
    
  end
end
