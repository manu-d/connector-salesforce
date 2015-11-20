class RenamedIdmapFields < ActiveRecord::Migration
  def up
    add_column :id_maps, :external_id, :string
    add_column :id_maps, :external_entity, :string

    IdMap.all.each do |idm|
      idm.external_id = idm.salesforce_id
      idm.external_entity = idm.salesforce_entity
      idm.save!
    end

    remove_column :id_maps, :salesforce_id
    remove_column :id_maps, :salesforce_entity
  end

  def down
    add_column :id_maps, :salesforce_id, :string
    add_column :id_maps, :salesforce_entity, :string

    IdMap.all.each do |idm|
      idm.salesforce_id = idm.external_id
      idm.salesforce_entity = idm.external_entity
      idm.save!
    end

    remove_column :id_maps, :external_id
    remove_column :id_maps, :external_entity
  end
end
