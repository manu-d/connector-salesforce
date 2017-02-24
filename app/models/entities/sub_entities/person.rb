class Entities::SubEntities::Person < Maestrano::Connector::Rails::SubEntityBase

  def self.external?
    false
  end

  def self.entity_name
    'Person'
  end

  def self.mapper_classes
    {
      'Lead' => Entities::SubEntities::LeadMapper,
      'Contact' => Entities::SubEntities::ContactMapper
    }
  end

  def self.references
    { 'Contact' => %w(organization_id) }
  end

  def self.object_name_from_connec_entity_hash(entity)
    "#{entity['first_name']} #{entity['last_name']}"
  end

  def update_external_entity(mapped_connec_entity, external_id, external_entity_name)
    # Cannot update a converted lead to SF
    if mapped_connec_entity['IsConverted']
      Maestrano::Connector::Rails::ConnectorLogger.log('debug', @organization, "Not sending update #{external_entity_name} (id=#{external_id}): #{mapped_connec_entity} to #{Maestrano::Connector::Rails::External.external_name}: lead is converted")
    else
      super
    end
  end

  def create_external_entity(mapped_connec_entity, external_entity_name)
    # Company is mandatory in SF lead and have no equivalent in Connec!
    mapped_connec_entity['Company'] = 'Undefined' if external_entity_name == 'Lead'
    super
  end
end
