require 'test_helper'

class BadgeTest < ActionController::IntegrationTest
  include IntegrationTestHelper

  def setup
    setup_plugin_configuration
    User.current = nil
    @user1 = create_contributor_license_and_user
    @user2 = create_contributor_license_and_user
    @user3 = User.generate!
    @project = Project.generate!
    @role = Role.generate!
    User.add_to_project(@user1, @project, @role)
    User.add_to_project(@user2, @project, @role)
    User.add_to_project(@user3, @project, @role)
  end

  should "show the CLA badge next each user name who has accepted" do
    visit "/projects/#{@project.identifier}"
    assert_response :success

    assert_select ".members" do
      # 2 CLA members, 3 total
      assert_select("a[class=?]", "icon icon-contributor-license", :count => 2)
      assert_select("a", :count => 3)
    end
  end

  protected
  
  def create_contributor_license_and_user
    user = User.generate!
    user.contributor_license = ContributorLicense.generate!(:state => 'accepted')
    user.save
    user.reload
  end
end
