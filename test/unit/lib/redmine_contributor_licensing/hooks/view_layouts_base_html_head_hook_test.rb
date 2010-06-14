require File.dirname(__FILE__) + '/../../../../test_helper'

class RedmineContributorLicensing::Hooks::ViewLayoutsBaseHtmlHeadTest < ActionController::TestCase
  include Redmine::Hook::Helper

  def controller
    @controller ||= ApplicationController.new
    @controller.response ||= ActionController::TestResponse.new
    @controller
  end

  def request
    @request ||= ActionController::TestRequest.new
  end
  
  def hook(args={})
    call_hook :view_layouts_base_html_head, args
  end

  context "#view_layouts_base_html_head" do
    context "for repository controller" do
      setup do
        @controller = RepositoriesController.new
        @controller.response ||= ActionController::TestResponse.new
        @response.body = hook
      end
      
      should "return the contributor-licensing.js" do
        assert @response.body.include?('contributor-licensing.js')
      end

      should "return the contributor-licensing.css" do
        assert @response.body.include?('contributor-licensing.js')
      end
    end

    context "for any other controller" do
      should "return an empty string" do
        @response.body = hook
        assert @response.body.blank?
      end
    end
  end
end
