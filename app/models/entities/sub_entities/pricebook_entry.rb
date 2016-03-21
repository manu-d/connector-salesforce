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

  def self.external_attributes
    %w(
      UnitPrice
      Product2Id
      Pricebook2Id
    )
    #Pricebook2Id is not used in mapper but is used for standard pricebook filtering
  end

  # --------------------------------------------
  #             Overloaded methods
  # --------------------------------------------
  def push_entities_to_connec_to(connec_client, mapped_external_entities_with_idmaps, connec_entity_name, organization)
    Maestrano::Connector::Rails::ConnectorLogger.log('info', organization, "Sending #{Maestrano::Connector::Rails::External.external_name} #{self.class.external_entity_name.pluralize} to Connec! #{connec_entity_name.pluralize}")
    mapped_external_entities_with_idmaps.each do |mapped_external_entity_with_idmap|
      external_entity = mapped_external_entity_with_idmap[:entity]
      idmap = mapped_external_entity_with_idmap[:idmap]

      if idmap.connec_id.blank?
        product_idmap = Entities::SubEntities::Product2.find_idmap({external_id: external_entity[:Product2Id], organization_id: organization.id})
        raise "Trying to push a price for a non existing or not pushed product (id: #{external_entity[:Product2Id]})" unless product_idmap && !product_idmap.connec_id.blank?
        idmap.update_attributes(connec_id: product_idmap.connec_id, connec_entity: connec_entity_name)
      end

      connec_entity = self.update_connec_entity(connec_client, external_entity, idmap.connec_id, connec_entity_name, organization)
      idmap.update_attributes(last_push_to_connec: Time.now)
    end
  end

  def get_external_entities(client, last_synchronization, organization, opts={})
    entities = super(client, last_synchronization, organization, opts)

    unless entities.empty?
      pricebook_id = Entities::Item.get_pricebook_id(client)
      entities.delete_if{|entity| entity['Pricebook2Id'] != pricebook_id}
    end
    entities
  end

end