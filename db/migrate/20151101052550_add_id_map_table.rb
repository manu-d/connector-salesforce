class AddIdMapTable < ActiveRecord::Migration
  def change
    create_table :id_maps do |t|
      t.string :connec_id
      t.string :connec_entity
      t.string :salesforce_id
      t.string :salesforce_entity
      t.integer :organization_id

      t.timestamps null: false
    end
  end
end
