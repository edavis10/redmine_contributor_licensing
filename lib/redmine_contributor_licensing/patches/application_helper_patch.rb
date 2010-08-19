module RedmineContributorLicensing
  module Patches
    module ApplicationHelperPatch
      def self.included(base)
        base.class_eval do
          unloadable

          # Identical to the link_to_user method but will add an extra css
          # classes to users who have accepted the contributor license.
          def link_to_user(user, options={})
            if user.is_a?(User)
              name = h(user.name(options[:format]))
              if user.active?
                css_class = user.accepted_contributor_license? ? 'icon icon-contributor-license' : '' # CLA change
                link_to(name, {:controller => 'users', :action => 'show', :id => user}, :class => css_class)

              else
                name
              end
            else
              h(user.to_s)
            end
          end

          
        end
      end
    end
  end
end
