class Maestrano::Connector::Rails::Entity
  include Maestrano::Connector::Rails::Concerns::Entity

  # Return an array of all the entities that the connector can synchronize
  # If you add new entities, you need to generate
  # a migration to add them to existing organizations
  def self.entities_list
    %w(organization person)
  end

  # Return an array of entities from the external app
  def self.get_external_entities_by_name(client, last_synchronization, entity_name, opts={})
    Rails.logger.info "Fetching #{@@external_name} #{entity_name.pluralize}"

    if opts[:full_sync] || last_synchronization.blank?
      fields = self.external_attributes.join(', ')
      entities = client.query("select Id, LastModifiedDate, #{fields} from #{entity_name} ORDER BY LastModifiedDate DESC")
    else
      entities = []
      ids = client.get_updated(entity_name, last_synchronization.updated_at, Time.now)['ids']
      ids.each do |id|
        entities << client.find(entity_name, id)
      end
    end

    Rails.logger.info "Source=#{@@external_name}, Entity=#{entity_name}, Response=#{entities}"
    entities
  end

  def self.create_entity_to_external_by_name(client, external_entity_name, mapped_connec_entity)
    Rails.logger.info "Create #{external_entity_name}: #{mapped_connec_entity} to #{@@external_name}"
    client.create!(self.external_entity_name, mapped_connec_entity)
  end

  def self.update_entity_to_external_by_name(client, external_entity_name, mapped_connec_entity, external_id)
    Rails.logger.info "Update #{external_entity_name} (id=#{external_id}): #{mapped_connec_entity} to #{@@external_name}"
    mapped_connec_entity['ID'] = external_id
    client.update!(external_entity_name, mapped_connec_entity)
  end
end