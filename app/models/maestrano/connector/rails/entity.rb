class Maestrano::Connector::Rails::Entity < Maestrano::Connector::Rails::EntityBase
  include Maestrano::Connector::Rails::Concerns::Entity

  # Return an array of entities from the external app
  def get_external_entities(external_entity_name, last_synchronization_date = nil)
    Maestrano::Connector::Rails::ConnectorLogger.log('info', @organization, "Fetching #{Maestrano::Connector::Rails::External.external_name} #{external_entity_name.pluralize}")

    if @opts[:full_sync] || last_synchronization_date.blank?
      describe = @external_client.describe(external_entity_name)
      fields = describe['fields'].map{|f| f['name']}.join(', ')
      entities = @external_client.query("select #{fields} from #{external_entity_name} ORDER BY LastModifiedDate DESC")
    else
      entities = get_updated_data(external_entity_name, last_synchronization_date)
    end

    Maestrano::Connector::Rails::ConnectorLogger.log('info', @organization, "Received data: Source=#{Maestrano::Connector::Rails::External.external_name}, Entity=#{external_entity_name}, Response=#{entities}")
    entities
  end

  def create_external_entity(mapped_connec_entity, external_entity_name)
    Maestrano::Connector::Rails::ConnectorLogger.log('info', @organization, "Sending create #{external_entity_name}: #{mapped_connec_entity} to #{Maestrano::Connector::Rails::External.external_name}")
    id = @external_client.create!(external_entity_name, mapped_connec_entity)
    # The restforce gem returns only the id, not the full entity.
    # We're rebuilding the hash for compatibility with the framework
    # This means it can't work with subentity id reference
    {'Id' => id}
  end

  def update_external_entity(mapped_connec_entity, external_id, external_entity_name)
    Maestrano::Connector::Rails::ConnectorLogger.log('info', @organization, "Sending update #{external_entity_name} (id=#{external_id}): #{mapped_connec_entity} to #{Maestrano::Connector::Rails::External.external_name}")
    mapped_connec_entity.merge!('Id' => external_id)
    @external_client.update!(external_entity_name, mapped_connec_entity)
    {}
  end

  def self.id_from_external_entity_hash(entity)
    entity['Id']
  end

  def self.last_update_date_from_external_entity_hash(entity)
    entity['LastModifiedDate']
  end

  def self.creation_date_from_external_entity_hash(entity)
    entity['CreatedDate']
  end

  def inactive_from_external_entity_hash?(entity)
    entity['IsDeleted'] || !entity['IsActive'] || false
  end

  private

    def get_updated_data(external_entity_name, last_synchronization_date)
      raise 'Cannot perform synchronizations less than a minute apart' if Time.now - last_synchronization_date < 1.minute
      # to avoid INVALID_REPLICATION_DATE error we set the startDate to maximum 30 days ago.
      replication_date = (last_synchronization_date > 30.days.ago) ? last_synchronization_date : 30.days.ago
      ids = @external_client.get_updated(external_entity_name, replication_date - 2.minutes, Time.now + 2.minutes)['ids']
      entities = ids.map { |id| @external_client.find(external_entity_name, id) }
    rescue Faraday::ClientError => e
      return entities = get_only_recent_data(external_entity_name) if e.message == 'INVALID_REPLICATION_DATE: startDate before org replication enabled date'
      raise e
    end

    def get_only_recent_data(external_entity_name)
      ids = @external_client.get_updated(external_entity_name, Time.now - 2.minute, Time.now + 2.minutes)['ids']
      ids.map { |id| @external_client.find(external_entity_name, id) }
    end
end
