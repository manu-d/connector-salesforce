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

  def map_to(name, entity)
    super.merge(id: [{id: entity['Product2Id'], provider: @organization.oauth_provider, realm: @organization.oauth_uid}])
  end

  # --------------------------------------------
  #             Overloaded methods
  # --------------------------------------------
  def get_external_entities(last_synchronization)
    entities = super

    unless entities.empty?
      pricebook_id = Entities::Item.get_pricebook_id(@external_client)
      entities.delete_if{|entity| entity['Pricebook2Id'] != pricebook_id}
    end
    entities
  end
end