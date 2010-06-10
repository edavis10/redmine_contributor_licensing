require 'test_helper'

class AdministerContributorLicensesTest < ActionController::IntegrationTest
  include IntegrationTestHelper

  setup do
    User.current = nil
    @user = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing', :admin => true)
  end

  should "list all Contributor Licenses" do
    @user1 = create_contributor_license_and_user
    @user2 = create_contributor_license_and_user
    @free_license = ContributorLicense.generate!(:user => nil)
    
    login_as
    click_link "Administration"
    click_link "Contributor Licenses"

    assert_equal "/contributor_licenses", current_url

    assert_select "table#contributor-licenses" do
      assert_select "tr#contributor-license-#{@user1.contributor_license.id}" do
        assert_select 'td', :text => /#{@user1.login}/
        assert_select 'td', :text => /#{@user1.contributor_license.state }/
      end

      assert_select "tr#contributor-license-#{@user2.contributor_license.id}" do
        assert_select 'td', :text => /#{@user2.login}/
        assert_select 'td', :text => /#{@user2.contributor_license.state }/
      end

      assert_select "tr#contributor-license-#{@free_license.id}", :count => 0
    end
    
  end

  should "show Contributor License" do
    @user1 = create_contributor_license_and_user
    @license = @user1.contributor_license
    @attachment = Attachment.generate!(:container => @license)
    
    login_as
    click_link "Administration"
    click_link "Contributor Licenses"

    assert_equal "/contributor_licenses", current_url

    click_link @user1.login
    assert_equal "/contributor_licenses/#{@license.id}", current_url

    assert_select 'p', :text => /#{@user1.name}/
    assert_select 'p', :text => /#{@license.state}/

    assert_select '.attachments' do
      assert_select 'a.icon.icon-attachment', :text => /#{@attachment.filename}/
    end
    
  end

  protected
  
  def create_contributor_license_and_user
    user = User.generate!
    user.contributor_license = ContributorLicense.generate!
    user.save
    user.reload
  end
  
end
