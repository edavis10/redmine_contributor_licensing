class AddAcceptedAtToContributorLicenses < ActiveRecord::Migration
  def self.up
    add_column :contributor_licenses, :accepted_at, :datetime
  end

  def self.down
    remove_column :contributor_licenses, :accepted_at
  end
end
