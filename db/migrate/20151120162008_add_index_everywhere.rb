class AddIndexEverywhere < ActiveRecord::Migration
  def change
    add_index :organizations, :uid

    add_index :users, :uid

    add_index :user_organization_rels, :organization_id
    add_index :user_organization_rels, :user_id

    add_index :id_maps, [:connec_id, :organization_id]
    add_index :id_maps, [:external_id, :organization_id]
    add_index :id_maps, :organization_id
  end
end
