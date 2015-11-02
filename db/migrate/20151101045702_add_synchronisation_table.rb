class AddSynchronisationTable < ActiveRecord::Migration
  def change
    create_table :synchronizations do |t|
      t.string  :provider
      t.integer :organization_id
      t.string  :tenant
      t.string  :status
      t.text    :message

      t.timestamps null: false
    end
  end
end
