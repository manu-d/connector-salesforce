class Entities::User < Maestrano::Connector::Rails::Entity

  def self.connec_entity_name
    'App user'
  end

  def self.external_entity_name
    'User'
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

  # No point in populating app user from Connec!
  def self.can_read_connec?
    false
  end

  def self.creation_date_from_external_entity_hash(entity)
    Time.now
  end

  def get_external_entities(external_entity_name, last_synchronization_date = nil)
    Maestrano::Connector::Rails::ConnectorLogger.log('info', @organization, "Fetching #{Maestrano::Connector::Rails::External.external_name} #{external_entity_name.pluralize}")
    raise 'Cannot perform synchronizations less than a minute apart' if last_synchronization_date && (Time.now - last_synchronization_date < 1.minute)

    describe = @external_client.describe(external_entity_name)
    fields = describe['fields'].map{|f| f['name']}.join(', ')
    entities = @external_client.query("select #{fields} from #{external_entity_name} ORDER BY LastModifiedDate DESC")

    Maestrano::Connector::Rails::ConnectorLogger.log('info', @organization, "Received data: Source=#{Maestrano::Connector::Rails::External.external_name}, Entity=#{external_entity_name}, Response=#{entities}")
    entities.reject { |e| e['Name'].in?(['Security User', 'Integration User', 'Chatter Expert']) }
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
