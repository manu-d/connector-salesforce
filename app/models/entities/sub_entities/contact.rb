class Entities::SubEntities::Contact < Maestrano::Connector::Rails::SubEntityBase

  def self.external?
    true
  end

  def self.entity_name
    'contact'
  end

  def map_to(name, entity, organization)
    case name
    when 'person'
      if id = entity['AccountId']
        idmap = Maestrano::Connector::Rails::IdMap.find_by(external_entity: 'account', external_id: id, organization_id: organization.id, connec_entity: 'organization')
        entity['AccountId'] = idmap ? idmap.connec_id : ''
      end
      Entities::SubEntities::ContactMapper.denormalize(entity)
    else
      raise "Impossible mapping from #{self.class.entity_name} to #{name}"
    end
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