class Entities::SubEntities::Person < Maestrano::Connector::Rails::SubEntityBase

  def external?
    false
  end

  def entity_name
    'person'
  end

  def map_to(name, entity, organization)
    case name
    when 'lead'
      Entities::SubEntities::LeadMapper.normalize(entity)
    when 'contact'
      if id = entity['organization_id']
        idmap = Maestrano::Connector::Rails::IdMap.find_by(connec_entity: 'organization', connec_id: id, organization_id: organization.id)
        entity['organization_id'] = idmap ? idmap.external_id : ''
      end
      Entities::SubEntities::ContactMapper.normalize(entity)
    else
      raise "Impossible mapping from #{self.entity_name} to #{name}"
    end
  end

  def update_entity_to_external(client, mapped_connec_entity, external_id, external_entity_name, organization)
    # Cannot update a converted lead to SF
    if mapped_connec_entity['IsConverted']
      Maestrano::Connector::Rails::ConnectorLogger.log('debug', organization, "Not sending update #{external_entity_name} (id=#{external_id}): #{mapped_connec_entity} to #{@@external_name}: lead is converted")
    else
      super
    end
  end

  def create_entity_to_external(client, mapped_connec_entity, external_entity_name, organization)
    # Company is mandatory in SF lead and have no equivalent in Connec!
    mapped_connec_entity['Company'] = 'Undefined' if external_entity_name == 'lead'
    super
  end
end