class AddLastPushedFieldsToIdMap < ActiveRecord::Migration
  def change
    add_column :id_maps, :last_push_to_connec , :datetime
    add_column :id_maps, :last_push_to_external , :datetime
  end
end
