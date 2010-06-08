require 'test_helper'

class ConfiguringTest < ActionController::IntegrationTest
  include IntegrationTestHelper

  setup do
    User.current = nil
    @user = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing', :admin => true)
  end

  should "load a wikitoolbar in the plugin settings" do
    login_as
    visit_plugin_configuration
    assert response.body.include?("jsToolBar($('settings_content'))")
  end

  should "use the currently saved setting" do
    Setting['plugin_redmine_contributor_licensing'] = {'content' => 'A saved string'}
    
    login_as
    visit_plugin_configuration
    assert_select 'textarea', :text => /A saved string/
  end
  

  should "save any content to the plugin's settings" do
    login_as
    visit_plugin_configuration

    fill_in "settings_content", :with => 'An updated content'
    click_button 'Apply'

    assert_equal "http://www.example.com/settings/plugin/redmine_contributor_licensing", current_url
    assert_select 'textarea', :text => /An updated content/

  end
  
  protected
  
  def visit_plugin_configuration
    click_link "Administration"
    click_link "Plugins"
    click_link "Configure"

    assert_equal "/settings/plugin/redmine_contributor_licensing", current_url
  end
  
end

