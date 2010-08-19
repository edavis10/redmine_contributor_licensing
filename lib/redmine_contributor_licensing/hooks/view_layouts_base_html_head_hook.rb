module RedmineContributorLicensing
  module Hooks
    class ViewLayoutsBaseHtmlHeadHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context={})
        content = stylesheet_link_tag('contributor-licensing.css', :plugin => 'redmine_contributor_licensing')
        
        if context[:controller] && context[:controller].is_a?(RepositoriesController)

          json_data = ContributorLicense.assigned_to_users.collect {|cl| {:name => cl.user.name, :state => cl.state}}.to_json
          
          return content +
            stylesheet_link_tag("contributor-licensing", :plugin => "redmine_contributor_licensing") +
            javascript_include_tag('jquery-1.4.2.min.js', :plugin => 'redmine_contributor_licensing') +
            javascript_include_tag('contributor-licensing', :plugin => 'redmine_contributor_licensing') +
            javascript_tag("jQuery.noConflict();") +
            javascript_tag("var contributors = #{json_data};")

        else
          content
        end
      end
    end
  end
end
