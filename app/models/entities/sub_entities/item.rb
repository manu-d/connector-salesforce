class Entities::SubEntities::Item < Maestrano::Connector::Rails::SubEntityBase

  def self.external?
    false
  end

  def self.entity_name
    'item'
  end

  def self.mapper_classes
    {
      'PricebookEntry' => Entities::SubEntities::PricebookEntryMapper,
      'Product2' => Entities::SubEntities::Product2Mapper
    }
  end

  def self.object_name_from_connec_entity_hash(entity)
    "[#{entity['code']}] #{entity['name']}"
  end

  def push_entities_to_external_to(external_client, mapped_connec_entities_with_idmaps, external_entity_name, organization)
    if external_entity_name == 'PricebookEntry' && !mapped_connec_entities_with_idmaps.empty?
      pricebook_id = Entities::Item.get_pricebook_id(external_client)

      mapped_connec_entities_with_idmaps.each do |mapped_entity_with_idmap|
        # Product2Id and Pricebook2Id needed for creation to SF
        if mapped_entity_with_idmap[:idmap].external_id.blank?
          mapped_entity_with_idmap[:entity]['Product2Id'] = Entities::SubEntities::Product2.find_idmap({connec_entity: 'item', connec_id: mapped_entity_with_idmap[:idmap].connec_id, organization_id: organization.id}).external_id
          mapped_entity_with_idmap[:entity]['Pricebook2Id'] = pricebook_id
        end
      end
    end

    super(external_client, mapped_connec_entities_with_idmaps, external_entity_name, organization)
  end

end