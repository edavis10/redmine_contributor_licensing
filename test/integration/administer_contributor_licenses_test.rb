require 'test_helper'

class AdministerContributorLicensesTest < ActionController::IntegrationTest
  include IntegrationTestHelper

  def setup
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

  should "approve Contributor License" do
    @user1 = create_contributor_license_and_user
    @license = @user1.contributor_license
    
    login_as
    click_link "Administration"
    click_link "Contributor Licenses"

    assert_equal "/contributor_licenses", current_url
    assert !@license.reload.accepted?
    click_link "Approve"
    
    assert_equal "http://www.example.com/contributor_licenses", current_url
    assert @license.reload.accepted?
    assert_equal @user, @license.accepted_by
  end

  should "allow creating a new Contributor License" do
    @faxed_user = User.generate!(:login => 'faxeduser', :firstname => 'Faxed', :lastname => 'User', :admin => false)

    login_as
    click_link "Administration"
    click_link "Contributor Licenses"

    assert_equal "/contributor_licenses", current_url

    click_link "New Contributor License"
    assert_equal "/contributor_licenses/new", current_url

    # Admins can pick a different user
    select "Faxed User", :from => 'User'
    click_button "Accept"

    assert_equal 'http://www.example.com/contributor_licenses', current_url
    assert_select '.flash', :text => /accepted/i

    license = @faxed_user.contributor_license
    assert license
    assert_equal 'accepted', license.state
    assert_equal @user, license.accepted_by
  end

  context "deleting" do
    should "a pending license" do
      @user1 = create_contributor_license_and_user
      @license = @user1.contributor_license
    
      login_as
      click_link "Administration"
      click_link "Contributor Licenses"

      assert_equal "/contributor_licenses", current_url
      assert !@license.reload.accepted?
      click_link "Delete"
    
      assert_equal "http://www.example.com/contributor_licenses", current_url
      assert_nil ContributorLicense.find_by_id(@license.id)
      assert_select '.flash', :text => /Contributor license was successfully destroyed/i
    end
    
    should "an approved license" do
      @user1 = create_contributor_license_and_user
      @license = @user1.contributor_license
      @license.acceptance = 'I agree'
      @license.accept!
      assert @license.reload.accepted?
    
      login_as
      click_link "Administration"
      click_link "Contributor Licenses"

      assert_equal "/contributor_licenses", current_url
      click_link "Delete"
    
      assert_equal "http://www.example.com/contributor_licenses", current_url
      assert ContributorLicense.find_by_id(@license.id)
      assert_select '.flash', :text => /Contributor license was unable to be destroyed/i
    end
  end

  context "reporting on" do
    setup do
      @no_license = User.generate!
      @pending_license = create_contributor_license_and_user
      @accepted_license = create_contributor_license_and_user
      @accepted_license.contributor_license.update_attribute(:state, 'accepted')
      [@no_license, @pending_license, @accepted_license].collect(&:reload)
      
      login_as
      click_link "Administration"
      click_link "Contributor Licenses"

      assert_equal "/contributor_licenses", current_url

      click_link "User Report"
      assert_response :success
      
    end
    
    should "all users" do
      assert_select "table" do
        assert_select "a", :text => /#{@no_license.name}/, :count => 1
        assert_select "a", :text => /#{@pending_license.name}/, :count => 1
        assert_select "a", :text => /#{@accepted_license.name}/, :count => 1
      end
    end

    should "who has not signed" do
      select "No license", :from => 'State'
      click_button 'Apply'
      
      assert_response :success

      assert_select "table" do
        assert_select "a", :text => /#{@no_license.name}/, :count => 1
        assert_select "a", :text => /#{@pending_license.name}/, :count => 0
        assert_select "a", :text => /#{@accepted_license.name}/, :count => 0
      end
    end
    
    should "who has signed" do
      select "Accepted license", :from => 'State'
      click_button 'Apply'
      
      assert_response :success

      assert_select "table" do
        assert_select "a", :text => /#{@no_license.name}/, :count => 0
        assert_select "a", :text => /#{@pending_license.name}/, :count => 0
        assert_select "a", :text => /#{@accepted_license.name}/, :count => 1
      end
    end
    
    should "who has a pending signature" do
      select "Pending license", :from => 'State'
      click_button 'Apply'
      
      assert_response :success

      assert_select "table" do
        assert_select "a", :text => /#{@no_license.name}/, :count => 0
        assert_select "a", :text => /#{@pending_license.name}/, :count => 1
        assert_select "a", :text => /#{@accepted_license.name}/, :count => 0
      end
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
