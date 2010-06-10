class AddAcceptedByIdToContributorLicenses < ActiveRecord::Migration
  def self.up
    add_column :contributor_licenses, :accepted_by_id, :integer
  end

  def self.down
    remove_column :contributor_licenses, :accepted_by_id
  end
end
