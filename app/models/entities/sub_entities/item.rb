class Entities::SubEntities::Item < Maestrano::Connector::Rails::SubEntityBase

  def self.external?
    false
  end

  def self.entity_name
    'Item'
  end

  def self.mapper_classes
    {
      'PricebookEntry' => Entities::SubEntities::PricebookEntryMapper,
      'Product2' => Entities::SubEntities::Product2Mapper
    }
  end

  def self.object_name_from_connec_entity_hash(entity)
    "[#{entity['reference']}] #{entity['name']}"
  end

  def self.find_or_create_idmap(organization_and_id)
    super(organization_and_id.except(:external_id))
  end

  def push_entities_to_external_to(mapped_connec_entities_with_idmaps, external_entity_name)
    if external_entity_name == 'PricebookEntry' && !mapped_connec_entities_with_idmaps.empty?
      entities = link_to_pricebook(mapped_connec_entities_with_idmaps)
    else
      entities = mapped_connec_entities_with_idmaps
    end

    super(entities, external_entity_name)
  end

  private
    def link_to_pricebook(mapped_connec_entities_with_idmaps)
      pricebook_id = Entities::Item.get_pricebook_id(@external_client)

      mapped_connec_entities_with_idmaps.map{|mapped_entity_with_idmap|
        # Pricebook2Id and Product2Id needed for creation to SF
        if mapped_entity_with_idmap[:idmap].external_id.blank?
          product2_idmap = Entities::SubEntities::Product2.find_idmap({connec_entity: 'item', connec_id: mapped_entity_with_idmap[:idmap].connec_id, organization_id: @organization.id})
          mapped_entity_with_idmap[:entity]['Product2Id'] = product2_idmap.external_id if product2_idmap
          mapped_entity_with_idmap[:entity]['Pricebook2Id'] = pricebook_id
        end
        mapped_entity_with_idmap
      }
    end

end