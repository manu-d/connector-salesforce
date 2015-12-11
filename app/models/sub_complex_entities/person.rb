class SubComplexEntities::Person < Maestrano::Connector::Rails::SubComplexEntityBase

  def external?
    false
  end

  def entity_name
    'person'
  end

  def mapper_classes
    [SubComplexEntities::ContactMapper, SubComplexEntities::LeadMapper]
  end

  def map_to(name, entity, organization)
    case name
    when 'lead'
      SubComplexEntities::LeadMapper.normalize(entity)
    when 'contact'
      if id = entity['organization_id']
        idmap = Maestrano::Connector::Rails::IdMap.find_by(connec_entity: 'organization', connec_id: id, organization_id: organization.id)
        entity['organization_id'] = idmap ? idmap.external_id : ''
      end
      SubComplexEntities::ContactMapper.normalize(entity)
    else
      raise "Impossible mapping from #{self.entity_name} to #{name}"
    end
  end

end