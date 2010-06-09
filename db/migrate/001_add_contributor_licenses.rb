class AddContributorLicenses < ActiveRecord::Migration
  def self.up
    create_table :contributor_licenses do |t|
      t.references :user
      t.string :state
      t.timestamps
    end

    add_index :contributor_licenses, :user_id
    add_index :contributor_licenses, :state
  end

  def self.down
    drop_table :contributor_licenses
  end
end
