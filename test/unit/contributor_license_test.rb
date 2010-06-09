require File.dirname(__FILE__) + '/../test_helper'

class ContributorLicenseTest < ActiveSupport::TestCase
  should_belong_to :user
  should_have_many :attachments

  should "initialize state to 'pending'" do
    assert_equal "pending", ContributorLicense.new.state
  end

  should_allow_values_for(:state, "pending", "accepted")
  should_not_allow_values_for(:state, "", nil, "garbarge", "long" * 1000, 1000)

  context "accept!" do
    context "should check the acceptance field" do
      setup do
        @license = ContributorLicense.new
      end
      
      should "pass with 'I agree'" do
        @license.acceptance = 'I agree'
        assert @license.accept!
      end
      
      should "pass with 'i AgrEe' (case insensitive)" do
        @license.acceptance = 'i AgrEe'
        assert @license.accept!
      end
      
      should "pass with 'this is a contract i agree with' (extra text)" do
        @license.acceptance = 'this is a contract i agree with'
        assert @license.accept!
      end

      should "fail without 'i agree'" do
        @license.acceptance = nil
        assert_equal false, @license.accept!

        @license.acceptance = ''
        assert_equal false, @license.accept!

        @license.acceptance = "I don't agree"
        assert_equal false, @license.accept!

        @license.acceptance = "garbarge" * 25
        assert_equal false, @license.accept!
      end
      
    end
    
    
    context "with a valid acceptance" do
      setup do
        @license = ContributorLicense.generate!(:acceptance => 'I agree')
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
end
