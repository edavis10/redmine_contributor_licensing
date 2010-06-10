require 'redmine'

config.gem 'inherited_resources', :version => '1.0.6'

Redmine::Plugin.register :redmine_contributor_licensing do
  name 'Redmine Contributor Licensing'
  author 'Eric Davis'
  description 'Allows Redmine users to sign Contributor Licensing Agreements in Redmine.'
  url 'https://projects.littlestreamsoftware.com/projects/redmine-cla'
  author_url 'http://www.littlestreamsoftware.com'
  version '0.1.0'
  requires_redmine :version_or_higher => '0.9.0'

  settings(:partial => 'settings/redmine_contributor_licensing',
           :default => {
             :content => 'Fill in your contributor licensing agreement here'
           })

  menu(:top_menu,
       :contributor_license,
       {:controller => 'contributor_licenses', :action => 'sign'},
       :caption => :contributor_licensing_title,
       :if => Proc.new {
         User.current.logged? &&
         !User.current.submitted_contributor_license?
       })

end

require 'dispatcher'
Dispatcher.to_prepare :redmine_contributor_licensing do
  require_dependency 'principal'
  require_dependency 'user'
  User.send(:include, RedmineContributorLicensing::Patches::UserPatch)
end
