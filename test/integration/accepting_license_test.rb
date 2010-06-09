require 'test_helper'

class AcceptingLicenseTest < ActionController::IntegrationTest
  include IntegrationTestHelper

  setup do
    User.current = nil
    @user = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing', :admin => true)
  end

  should "show the top menu link to a user who hasn't accepted yet" do
    login_as
    visit '/'
    assert_response :success
    assert_select "#top-menu a.contributor-license"
  end
  
  should "not show the top menu link to users who have already accepted"
end

