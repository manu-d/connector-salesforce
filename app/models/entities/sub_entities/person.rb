class Entities::SubEntities::Person < Maestrano::Connector::Rails::SubEntityBase

  def self.external?
    false
  end

  def self.entity_name
    'person'
  end

  def self.mapper_classes
    {
      'lead' => Entities::SubEntities::LeadMapper,
      'contact' => Entities::SubEntities::ContactMapper
    }
  end

  def self.references
    {
      'contact' => [{reference_class: Entities::Organization, connec_field: 'organization_id', external_field: 'AccountId'}]
    }
  end

  def self.object_name_from_connec_entity_hash(entity)
    "#{entity['first_name']} #{entity['last_name']}"
  end

  def update_external_entity(client, mapped_connec_entity, external_id, external_entity_name, organization)
    # Cannot update a converted lead to SF
    if mapped_connec_entity['IsConverted']
      Maestrano::Connector::Rails::ConnectorLogger.log('debug', organization, "Not sending update #{external_entity_name} (id=#{external_id}): #{mapped_connec_entity} to #{Maestrano::Connector::Rails::External.external_name}: lead is converted")
    else
      super
    end
  end

  def create_external_entity(client, mapped_connec_entity, external_entity_name, organization)
    # Company is mandatory in SF lead and have no equivalent in Connec!
    mapped_connec_entity['Company'] = 'Undefined' if external_entity_name == 'lead'
    super
  end
end