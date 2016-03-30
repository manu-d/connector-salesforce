class Entities::SubEntities::Product2 < Maestrano::Connector::Rails::SubEntityBase

  def self.external?
    true
  end

  def self.entity_name
    'Product2'
  end

  def self.mapper_classes
    {
      'item' => Entities::SubEntities::Product2Mapper
    }
  end

  def self.object_name_from_external_entity_hash(entity)
    "[#{entity['ProductCode']}] #{entity['Name']}"
  end

  def self.external_attributes
    %w(
      Name
      ProductCode
      Description
    )
  end

end