# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

# Ensure that we are using the temporary fixture path
Engines::Testing.set_fixture_path

require "webrat"

Webrat.configure do |config|
  config.mode = :rails
end

class ActiveSupport::TestCase
  def configure_plugin(fields={})
    Setting.plugin_redmine_contributor_licensing = fields.stringify_keys
  end

  def setup_plugin_configuration
    configure_plugin({'content' => "h1. Here is some content\n\n_Sign below_"})
  end

  # Cleanup current_url to remove the host; sometimes it's present, sometimes it's not
  def current_path
    return nil if current_url.nil?
    return current_url.gsub("http://www.example.com","")
  end

end

module IntegrationTestHelper
  def login_as(user="existing", password="existing")
    visit "/login"
    fill_in 'Login', :with => user
    fill_in 'Password', :with => password
    click_button 'login'
    assert_response :success
    assert User.current.logged?
  end
end

def User.add_to_project(user, project, role)
  Member.generate!(:principal => user, :project => project, :roles => [role])
end
