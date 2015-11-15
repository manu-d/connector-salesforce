class AddPartialToSynchronizations < ActiveRecord::Migration
  def change
    add_column :synchronizations, :partial, :boolean, default: false
  end
end
