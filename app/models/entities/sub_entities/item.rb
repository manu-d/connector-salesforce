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

  def self.references
    {
      'PricebookEntry' => %w(item_id)
    }
  end

  def self.object_name_from_connec_entity_hash(entity)
    "[#{entity['code']}] #{entity['name']}"
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
        # Pricebook2Id needed for creation to SF
        if mapped_entity_with_idmap[:idmap].external_id.blank?
          mapped_entity_with_idmap[:entity]['Pricebook2Id'] = pricebook_id
        end
        mapped_entity_with_idmap
      }
    end

end