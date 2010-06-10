require File.dirname(__FILE__) + '/../test_helper'

class ContributorLicensesControllerTest < ActionController::TestCase
  should_have_before_filter :require_admin, :except => [:sign, :create, :upload]
end
