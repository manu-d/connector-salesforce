class Entities::SubEntities::Product2 < Maestrano::Connector::Rails::SubEntityBase

  def self.external?
    true
  end

  def self.entity_name
    'Product2'
  end

  def self.mapper_classes
    {
      'Item' => Entities::SubEntities::Product2Mapper
    }
  end

  def push_entities_to_connec_to(mapped_external_entities_with_idmaps, connec_entity_name)
    return unless @organization.push_to_connec_enabled?(self)

    Maestrano::Connector::Rails::ConnectorLogger.log('info', @organization, "Sending #{Maestrano::Connector::Rails::External.external_name} #{self.class.external_entity_name.pluralize} to Connec! #{connec_entity_name.pluralize}")

    mapped_external_entities_with_idmaps.each do |mapped_external_entity_with_idmap|
      id = mapped_external_entity_with_idmap[:idmap].connec_id
      next unless id
      # For updates, we remove the price fields as it used only on creation
      mapped_external_entity_with_idmap[:entity].delete('sale_price')
      mapped_external_entity_with_idmap[:entity].delete('purchase_price')
    end

    proc = ->(mapped_external_entity_with_idmap) { batch_op('post', mapped_external_entity_with_idmap[:entity], nil, self.class.normalize_connec_entity_name(connec_entity_name)) }
    batch_calls(mapped_external_entities_with_idmaps, proc, connec_entity_name)
  end

  def self.object_name_from_external_entity_hash(entity)
    "[#{entity['ProductCode']}] #{entity['Name']}"
  end
end
