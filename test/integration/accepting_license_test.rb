require 'test_helper'

class AcceptingLicenseTest < ActionController::IntegrationTest
  include IntegrationTestHelper

  def setup
    setup_plugin_configuration
    User.current = nil
    @user = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing', :admin => true)
  end

  should "not allow anonymous users to access the signing page" do
    assert !User.current.logged?
    visit '/'
    assert_response :success

    assert_select "#top-menu a.contributor-license", :count => 0

    visit '/contributor_licenses/sign'
    assert_response :success
    assert_match /login\?back_url/, current_path
  end
  
  should "not allow anonymous users to fake signing a license agreement (raw POST)" do
    assert !User.current.logged?

    assert_no_difference('ContributorLicense.count') do
      post '/contributor_licenses', :clickwrap => 'true', :acceptance => 'I agree'
      assert_response :redirect
    end
  end

  should "not allow anonymous users to upload a license agreement" do
    assert !User.current.logged?

    visit '/contributor_licenses/upload'
    assert_response :success
    assert_match /login\?back_url/, current_path
  end

  should "show the top menu link to a user who hasn't accepted yet" do
    login_as
    visit '/'
    assert_response :success
    assert_select "#top-menu a.contributor-license"
  end

  context "for a user who has already submitted a Contributor License" do
    setup do
      @license = ContributorLicense.generate! # Doesn't need to be accepted
      @user.contributor_license = @license
      login_as
    end
    
    should "not show the top menu link" do
      visit '/'
      assert_response :success
      assert_select "#top-menu a.contributor-license", :count => 0
    end

    should "not allow access to the signing page again" do
      visit '/contributor_licenses/sign'
      assert_response :success
      assert_equal '/', current_path
    end
  
    should "re-signing a license agreement (raw POST)" do
      assert_no_difference('ContributorLicense.count') do
        post '/contributor_licenses', :clickwrap => 'true', :acceptance => 'I agree'
        assert_response :redirect
      end
    end

    should "re-uploading a license agreement" do
      visit '/contributor_licenses/upload'
      assert_response :success
      assert_equal '/', current_path
    end

  end

  should "show the license content on the CLA page" do
    login_as
    visit '/'
    click_link "Contributor License"
    assert_equal '/contributor_licenses/sign', current_url

    assert_select 'div#license-content', :text => /Here is some content/
  end
  
  should "allow entering 'I agree' to accept a CLA" do
    login_as
    visit '/'
    click_link "Contributor License"
    assert_equal '/contributor_licenses/sign', current_url

    fill_in "acceptance", :with => 'i AgRee with you'
    click_button "Accept"

    assert_equal 'http://www.example.com/', current_url
    assert_select '.flash', :text => /accepted/i

    license = @user.contributor_license
    assert_equal 'accepted', license.state
    assert_equal @user, license.accepted_by
  end
  
  should "check that 'I agree' was used to accept a CLA" do
    login_as
    visit '/'
    click_link "Contributor License"
    assert_equal '/contributor_licenses/sign', current_url

    fill_in "acceptance", :with => 'junk'
    click_button "Accept"

    assert_equal '/contributor_licenses', current_url
    assert_select '.errorExplanation', :text => /to accept/

    assert_select 'div#license-content', :text => /Here is some content/

    assert_nil @user.reload.contributor_license
  end

  should "block submitting multiple CLAs" do
    login_as
    visit '/'
    click_link "Contributor License"
    assert_equal '/contributor_licenses/sign', current_url

    fill_in "acceptance", :with => 'i AgRee with you'
    click_button "Accept"

    assert_equal 'http://www.example.com/', current_url
    assert_select '.flash', :text => /accepted/i

    visit '/contributor_licenses/sign' # Direct url access
    assert_response :success
    assert_equal '/', current_path

    assert_equal 1, ContributorLicense.count(:conditions => {:user_id => @user.id})
  end


  should "allow uploading a file to accept a CLA" do
    login_as
    visit '/'
    click_link "Contributor License"
    assert_equal '/contributor_licenses/sign', current_url

    click_link "Upload license agreement"
    assert_equal '/contributor_licenses/upload', current_url

    attach_file "attachments[1][file]", File.join(File.dirname(__FILE__), '..', 'fixtures', 'files', 'sample.pdf')
    click_button "Accept"

    assert_equal 'http://www.example.com/', current_url
    assert_select '.flash', :text => /pending/i

    license = @user.contributor_license
    assert_equal 'pending', license.state
    assert_equal 1, license.attachments.length
  end
  
end

