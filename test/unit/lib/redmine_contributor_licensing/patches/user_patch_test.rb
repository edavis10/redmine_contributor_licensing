require File.dirname(__FILE__) + '/../../../../test_helper'

class RedmineContributorLicensing::Patches::UserTest < ActionController::TestCase

  context "User" do
    subject {User.new}
    
    should_have_one :contributor_license
  end
  
end
