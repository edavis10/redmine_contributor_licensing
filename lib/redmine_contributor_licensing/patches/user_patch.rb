module RedmineContributorLicensing
  module Patches
    module UserPatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          
          has_one :contributor_license, :dependent => :nullify
          delegate :accepted_contributor_license?, :to => :contributor_license, :allow_nil => true

          named_scope :with_contributor_license_of, lambda {|state|
            case state
            when 'none'
              {
                :include => :contributor_license,
                :conditions => ["#{ContributorLicense.table_name}.id is NULL"]
              }
            when 'pending'
              {
                :include => :contributor_license,
                :conditions => ["#{ContributorLicense.table_name}.state = ?", 'pending']
              }
            when 'accepted'
              {
                :include => :contributor_license,
                :conditions => ["#{ContributorLicense.table_name}.state = ?", 'accepted']
              }
            else # All, matches ''
              {}
            end
          }
          
          def submitted_contributor_license?
            contributor_license.present?
          end

        end
      end

      module ClassMethods
      end

      module InstanceMethods
      end
    end
  end
end
