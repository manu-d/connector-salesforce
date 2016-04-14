class Maestrano::Connector::Rails::Entity
  include Maestrano::Connector::Rails::Concerns::Entity

  # Return an array of all the entities that the connector can synchronize
  # If you add new entities, you need to generate
  # a migration to add them to existing organizations
  def self.entities_list
    %w(organization contact_and_lead item opportunity)
  end

  # Return an array of entities from the external app
  def get_external_entities(client, last_synchronization, organization, opts={})
    Maestrano::Connector::Rails::ConnectorLogger.log('info', organization, "Fetching #{Maestrano::Connector::Rails::External.external_name} #{self.class.external_entity_name.pluralize}")

    if opts[:full_sync] || last_synchronization.blank?
      describe = client.describe(self.class.external_entity_name)
      fields = describe['fields'].map{|f| f['name']}.join(', ')
      entities = client.query("select #{fields} from #{self.class.external_entity_name} ORDER BY LastModifiedDate DESC")
    else
      entities = []
      raise 'Cannot perform synchronizations less than a minute apart' unless Time.now - last_synchronization.updated_at > 1.minute
      ids = client.get_updated(self.class.external_entity_name, last_synchronization.updated_at, Time.now)['ids']
      ids.each do |id|
        entities << client.find(self.class.external_entity_name, id)
      end
    end

    Maestrano::Connector::Rails::ConnectorLogger.log('info', organization, "Received data: Source=#{Maestrano::Connector::Rails::External.external_name}, Entity=#{self.class.external_entity_name}, Response=#{entities}")
    entities
  end

  def create_external_entity(client, mapped_connec_entity, external_entity_name, organization)
    Maestrano::Connector::Rails::ConnectorLogger.log('info', organization, "Sending create #{external_entity_name}: #{mapped_connec_entity} to #{Maestrano::Connector::Rails::External.external_name}")
    client.create!(external_entity_name, mapped_connec_entity)
  end

  def update_external_entity(client, mapped_connec_entity, external_id, external_entity_name, organization)
    Maestrano::Connector::Rails::ConnectorLogger.log('info', organization, "Sending update #{external_entity_name} (id=#{external_id}): #{mapped_connec_entity} to #{Maestrano::Connector::Rails::External.external_name}")
    mapped_connec_entity['Id'] = external_id
    client.update!(external_entity_name, mapped_connec_entity)
  end

  def self.id_from_external_entity_hash(entity)
    entity['Id']
  end

  def self.last_update_date_from_external_entity_hash(entity)
    entity['LastModifiedDate']
  end
end