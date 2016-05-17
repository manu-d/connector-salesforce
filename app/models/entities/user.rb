class Entities::User < Maestrano::Connector::Rails::Entity

  def self.connec_entity_name
    "App user"
  end

  def self.external_entity_name
    "User"
  end

  def self.mapper_class
    UserMapper
  end

  def self.object_name_from_connec_entity_hash(entity)
    "#{entity['first_name']} #{entity['last_name']}"
  end

  def self.object_name_from_external_entity_hash(entity)
    "#{entity['FirstName']} #{entity['LastName']}"
  end

  def get_external_entities(last_synchronization)
    super.except{|u| ['Security User', 'Integration User', 'Chatter Expert'].include?(u)}
  end

  # No point in populating app user from Connec!
  def self.can_read_connec?
    false
  end

end

class UserMapper
  extend HashMapper

  map from('first_name'),  to('FirstName')
  map from('last_name'),  to('LastName')

  map from('address_work/billing/line1'), to('Street')
  map from('address_work/billing/city'), to('City')
  map from('address_work/billing/region'), to('State')
  map from('address_work/billing/postal_code'), to('PostalCode')
  map from('address_work/billing/country'), to('Country')

  map from('email/address'), to('Email')
  map from('phone_work/landline'), to('Phone')
  map from('phone_work/mobile'), to('MobilePhone')
  map from('phone_work/fax'), to('Fax')
end