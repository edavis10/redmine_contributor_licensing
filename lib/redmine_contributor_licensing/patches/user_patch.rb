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
        end
      end

      module ClassMethods
      end

      module InstanceMethods
      end
    end
  end
end
