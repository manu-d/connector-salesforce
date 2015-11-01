class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :provider
      t.string :uid
      t.string :name
      t.string :tenant

      t.string :oauth_provider
      t.string :oauth_uid
      t.string :oauth_token
      t.string :refresh_token
      t.string :instance_url

      t.timestamps null: false
    end

    create_table :user_organization_rels do |t|
      t.integer :user_id
      t.integer :organization_id

      t.timestamps
    end
  end
end
