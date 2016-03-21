class Entities::SubEntities::Contact < Maestrano::Connector::Rails::SubEntityBase

  def self.external?
    true
  end

  def self.entity_name
    'contact'
  end

  def self.references
    {
      'person' => [{reference_class: Entities::Organization, connec_field: 'organization_id', external_field: 'AccountId'}]
    }
  end

  def self.mapper_classes
    {
      'person' => Entities::SubEntities::ContactMapper
    }
  end


  def self.object_name_from_external_entity_hash(entity)
    "#{entity['FirstName']} #{entity['LastName']}"
  end

  def self.external_attributes
    %w(
      AccountId
      Salutation
      FirstName
      LastName
      Title
      Birthdate
      MailingStreet
      MailingCity
      MailingState
      MailingPostalCode
      MailingCountry
      OtherStreet
      OtherCity
      OtherState
      OtherPostalCode
      OtherCountry
      Email
      Phone
      OtherPhone
      MobilePhone
      Fax
      HomePhone
      LeadSource
    )
  end

end