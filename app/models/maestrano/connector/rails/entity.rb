class Maestrano::Connector::Rails::Entity
  include Maestrano::Connector::Rails::Concerns::Entity

  # Return an array of entities from the external app
  def get_external_entities(last_synchronization)
    Maestrano::Connector::Rails::ConnectorLogger.log('info', @organization, "Fetching #{Maestrano::Connector::Rails::External.external_name} #{self.class.external_entity_name.pluralize}")

    if @opts[:full_sync] || last_synchronization.blank?
      describe = @external_client.describe(self.class.external_entity_name)
      fields = describe['fields'].map{|f| f['name']}.join(', ')
      entities = @external_client.query("select #{fields} from #{self.class.external_entity_name} ORDER BY LastModifiedDate DESC")
    else
      entities = []
      raise 'Cannot perform synchronizations less than a minute apart' unless Time.now - last_synchronization.updated_at > 1.minute
      ids = @external_client.get_updated(self.class.external_entity_name, last_synchronization.updated_at, Time.now)['ids']
      ids.each do |id|
        entities << @external_client.find(self.class.external_entity_name, id)
      end
    end

    Maestrano::Connector::Rails::ConnectorLogger.log('info', @organization, "Received data: Source=#{Maestrano::Connector::Rails::External.external_name}, Entity=#{self.class.external_entity_name}, Response=#{entities}")
    entities
  end

  def create_external_entity(mapped_connec_entity, external_entity_name)
    Maestrano::Connector::Rails::ConnectorLogger.log('info', @organization, "Sending create #{external_entity_name}: #{mapped_connec_entity} to #{Maestrano::Connector::Rails::External.external_name}")
    @external_client.create!(external_entity_name, mapped_connec_entity)
  end

  def update_external_entity(mapped_connec_entity, external_id, external_entity_name)
    Maestrano::Connector::Rails::ConnectorLogger.log('info', @organization, "Sending update #{external_entity_name} (id=#{external_id}): #{mapped_connec_entity} to #{Maestrano::Connector::Rails::External.external_name}")
    mapped_connec_entity.merge!('Id' => external_id)
    @external_client.update!(external_entity_name, mapped_connec_entity)
  end

  def self.id_from_external_entity_hash(entity)
    entity['Id']
  end

  def self.last_update_date_from_external_entity_hash(entity)
    entity['LastModifiedDate']
  end

  def inactive_from_external_entity_hash?(entity)
    entity['IsDeleted'] || !entity['IsActive'] || false
  end
end