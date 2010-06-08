require 'redmine'

Redmine::Plugin.register :redmine_contributor_licensing do
  name 'Redmine Contributor Licensing'
  author 'Eric Davis'
  description 'Allows Redmine users to sign Contributor Licensing Agreements in Redmine.'
  url 'https://projects.littlestreamsoftware.com/projects/redmine-cla'
  author_url 'http://www.littlestreamsoftware.com'
  version '0.1.0'
  requires_redmine :version_or_higher => '0.9.0'
end
