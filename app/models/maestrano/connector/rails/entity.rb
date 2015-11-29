class Maestrano::Connector::Rails::Entity
  include Maestrano::Connector::Rails::Concerns::Entity

  # Return an array of all the entities that the connector can synchronize
  # If you add new entities, you need to generate
  # a migration to add them to existing organizations
  def self.entities_list
    %w(organization person)
  end

  # Return an array of entities from the external app
  def get_external_entities(client, last_synchronization, opts={})
    Rails.logger.info "Fetching #{@@external_name} #{self.external_entity_name.pluralize}"
    # TODO full sync || !last_synchronization
    entities = []
    ids = client.get_updated(self.external_entity_name, 3.week.ago, Time.now)['ids']
    # ids = client.get_updated(self.external_entity_name, last_synchronization.updated_at, Time.now)['ids']
    ids.each do |id|
      entities << client.find(self.external_entity_name, id)
    end
    Rails.logger.info "Source=#{@@external_name}, Entity=#{self.external_entity_name}, Response=#{entities}"
    entities
  end

  def create_entity_to_external(client, mapped_connec_entity)
    Rails.logger.info "Create #{self.external_entity_name}: #{mapped_connec_entity} to #{@@external_name}"
    client.create!(self.external_entity_name, mapped_connec_entity)
  end

  def update_entity_to_external(client, mapped_connec_entity, external_id)
    Rails.logger.info "Update #{self.external_entity_name} (id=#{external_id}): #{mapped_connec_entity} to #{@@external_name}"
    mapped_connec_entity['ID'] = external_id
    client.update!(self.external_entity_name, mapped_connec_entity)
  end

  # * Discards entities that do not need to be pushed because they have not been updated since their last push
  # * Discards entities from one of the two source in case of conflict
  # * Maps not discarded entities and associates them with their idmap, or create one if there isn't any
  def consolidate_and_map_data(connec_entities, external_entities, organization)
    external_entities.map!{|entity|
      idmap = IdMap.find_by(external_id: entity['Id'], external_entity: self.external_entity_name, organization_id: organization.id)

      # No idmap: creating one, nothing else to do
      unless idmap
        next {entity: self.map_to_connec(entity), idmap: IdMap.create(external_id: entity['Id'], external_entity: self.external_entity_name, organization_id: organization.id)}
      end

      # Entity has not been modified since its last push to connec!
      next nil if idmap.last_push_to_connec && idmap.last_push_to_connec > entity['LastModifiedDate']

      # Check for conflict with entities from connec!
      if idmap.connec_id && connec_entity = connec_entities.detect{|connec_entity| connec_entity['id'] == idmap.connec_id}
        # We keep the most recently updated entity
        if connec_entity['updated_at'] < entity['LastModifiedDate']
          Rails.logger.info "Conflict between #{@@external_name} #{self.external_entity_name} #{entity} and Connec! #{self.connec_entity_name} #{connec_entity}. Entity from #{@@external_name} kept"
          connec_entities.delete(connec_entity)
          {entity: self.map_to_connec(entity), idmap: idmap}
        else
          Rails.logger.info "Conflict between #{@@external_name} #{self.external_entity_name} #{entity} and Connec! #{self.connec_entity_name} #{connec_entity}. Entity from Connec! kept"
          nil
        end
      end
    }.compact!

    connec_entities.map!{|entity|
      self.map_to_external_with_idmap(entity, organization)
    }.compact!
  end
end