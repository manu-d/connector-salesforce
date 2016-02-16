class Entities::SubEntities::Lead < Maestrano::Connector::Rails::SubEntityBase

  def external?
    true
  end

  def entity_name
    'lead'
  end

  def map_to(name, entity, organization)
    case name
    when 'person'
      Entities::SubEntities::LeadMapper.denormalize(entity).merge(is_lead: true, is_customer: false)
    else
      raise "Impossible mapping from #{self.entity_name} to #{name}"
    end
  end

  def external_attributes
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