class Entities::SubEntities::PricebookEntry < Maestrano::Connector::Rails::SubEntityBase

  def self.external?
    true
  end

  def self.entity_name
    'PricebookEntry'
  end

  def self.mapper_classes
    {
      'item' => Entities::SubEntities::PricebookEntryMapper
    }
  end

  def self.object_name_from_external_entity_hash(entity)
    "Price for #{entity['Product2Id']}"
  end

  # --------------------------------------------
  #             Overloaded methods
  # --------------------------------------------
  def push_entities_to_connec_to(connec_client, mapped_external_entities_with_idmaps, connec_entity_name, organization)
    # Link pricebook entry to their product
    linked_mapped_external_entities = link_and_filter_pricebook_entry(mapped_external_entities_with_idmaps, organization)
    super(connec_client, linked_mapped_external_entities, connec_entity_name, organization)
  end

  def get_external_entities(client, last_synchronization, organization, opts={})
    entities = super(client, last_synchronization, organization, opts)

    unless entities.empty?
      pricebook_id = Entities::Item.get_pricebook_id(client)
      entities.delete_if{|entity| entity['Pricebook2Id'] != pricebook_id}
    end
    entities
  end

  private
    def link_and_filter_pricebook_entry(mapped_external_entities_with_idmaps, organization)
      linked_mapped_external_entities = mapped_external_entities_with_idmaps.each do |mapped_external_entity_with_idmap|
        external_entity = mapped_external_entity_with_idmap[:entity]
        idmap = mapped_external_entity_with_idmap[:idmap]

        if idmap.connec_id.blank?
          product_idmap = Entities::SubEntities::Product2.find_idmap({external_id: external_entity[:Product2Id], organization_id: organization.id})
          if product_idmap && product_idmap.connec_id
            idmap.update_attributes(connec_id: product_idmap.connec_id)
          else
            idmap.update_attributes(message: "Trying to push a price for a non existing or not pushed product (id: #{external_entity[:Product2Id]})")
            mapped_external_entities_with_idmaps.delete(mapped_external_entity_with_idmap)
          end
        end
      end
      linked_mapped_external_entities
    end

end