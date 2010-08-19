require 'test_helper'

class ClaSignersBlockTest < ActionController::IntegrationTest
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

  should "show the CLA signers at the bottom of the members block" do
    visit "/projects/#{@project.identifier}"
    assert_response :success

    assert_select "div.members.box" do
      assert_select ".members" do
        assert_select "p", :text => /Contributor License Signers:/ do
          assert_select "a", :count => 2
        end
      end
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
