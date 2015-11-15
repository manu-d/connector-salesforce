class AddSynchronizedEntityToOrganization < ActiveRecord::Migration
  def up
    add_column :organizations, :synchronized_entities, :string

    h = {organization: true, person: true}

    Organization.all.each do |o|
      o.synchronized_entities = h
      o.save!
    end
  end

  def down
    remove_column :organizations, :synchronized_entities, :string
  end
end
