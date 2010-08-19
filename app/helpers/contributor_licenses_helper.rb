module ContributorLicensesHelper
  def contributor_licenses_menu(actions, contributor_license = nil)
    menu_items = []
    menu_items << link_to(l(:contributor_licensing_label_plural), contributor_licenses_path, :class => 'icon icon-multiple') if actions.include?(:index)
    menu_items << link_to(l(:text_new_contributor_license), new_contributor_license_path, :class => 'icon icon-add')

    if contributor_license
      menu_items << link_to(l(:contributor_licensing_label), contributor_license_path(contributor_license), :class => 'icon icon-document') if actions.include?(:show)

      menu_items << link_to(l(:contributor_licensing_label_approve), approve_contributor_license_path(contributor_license), :method => :put, :class => 'icon icon-edit') unless contributor_license.accepted? && actions.include?(:delete)
      
      menu_items << link_to(l(:button_delete), contributor_license_path(contributor_license), :confirm => l(:text_are_you_sure), :method => :delete, :class => 'icon icon-del') if actions.include?(:delete)
    end

    menu_items << link_to(l(:text_contributor_report), report_contributor_licenses_path, :class => 'icon icon-report')

    css = "background-image: url(../images/changeset.png);"
    menu_items << link_to(l(:button_configure), {:controller => 'settings', :action => 'plugin', :id => 'redmine_contributor_licensing'}, :class => 'icon', :style => css)

    return content_tag(:div, menu_items.join(' '), :class => "contextual")
  end

  def license_status_options_for_select(selected)
    options_for_select([[l(:label_all), ''], 
                        [l(:text_no_license), 'none'],
                        [l(:text_pending_license), 'pending'],
                        [l(:text_accepted_license), 'accepted']], selected)
  end
end
