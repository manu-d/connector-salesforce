class AddUserToSynchronizedEntities < ActiveRecord::Migration
  def change
    Maestrano::Connector::Rails::Organization.all.each do |o|
      se = o.synchronized_entities
      se = {user: true}.merge(se)
      o.update(synchronized_entities: se)

      if o.synchronized_entities[:opportunity]
        Maestrano::Connector::Rails::SynchronizationJob.perform_later(o, {forced: true, full_sync: true, only_entities: %w(user opportunity)})
      else
        Maestrano::Connector::Rails::SynchronizationJob.perform_later(o, {forced: true, full_sync: true, only_entities: %w(user)})
      end
    end
  end
end
