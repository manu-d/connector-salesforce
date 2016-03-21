class Entities::SubEntities::Lead < Maestrano::Connector::Rails::SubEntityBase

  def self.external?
    true
  end

  def self.entity_name
    'lead'
  end

  def self.mapper_classes
    {
      'person' => Entities::SubEntities::LeadMapper
    }
  end

  def self.object_name_from_external_entity_hash(entity)
    "#{entity['FirstName']} #{entity['LastName']}"
  end

  def self.external_attributes
    %w(
      Street
      City
      State
      PostalCode
      Country
      Email
      Fax
      LeadSource
      MobilePhone
      Salutation
      FirstName
      LastName
      Phone
      Title
      Description
      Status
      ConvertedDate
    )
      # Company
  end

end