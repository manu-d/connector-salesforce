class Entities::SubEntities::PricebookEntry < Maestrano::Connector::Rails::SubEntityBase

  def self.external?
    true
  end

  def self.entity_name
    'PricebookEntry'
  end

  def self.mapper_classes
    {
      'Item' => Entities::SubEntities::PricebookEntryMapper
    }
  end

  def self.object_name_from_external_entity_hash(entity)
    "Price for #{entity['Product2Id']}"
  end

  def map_to(name, entity, idmap = nil)
    super.merge(id: [{id: entity['Product2Id'], provider: @organization.oauth_provider, realm: @organization.oauth_uid}])
  end

  def self.currency_check_fields
    %w(sale_price purchase_price)
  end

  # --------------------------------------------
  #             Overloaded methods
  # --------------------------------------------
  def get_external_entities(external_entity_name, last_synchronization_date = nil)
    entities = super

    unless entities.empty?
      pricebook_id = Entities::Item.get_pricebook_id(@external_client)
      entities.delete_if{|entity| entity['Pricebook2Id'] != pricebook_id}
    end
    entities
  end
end
