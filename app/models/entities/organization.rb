class Entities::Organization < Maestrano::Connector::Rails::Entity

  def self.connec_entity_name
    'Organization'
  end

  def self.external_entity_name
    'Account'
  end

  def self.mapper_class
    OrganizationMapper
  end

  def self.object_name_from_connec_entity_hash(entity)
    entity['name']
  end

  def self.object_name_from_external_entity_hash(entity)
    entity['Name']
  end

  def before_sync(last_synchronization_date)
    @opts[:has_fax] = @external_client.describe('Account')['fields'].map{|f| f['name']}.include?('Fax')
  rescue => e
  end
end

class OrganizationMapper
  extend HashMapper

  after_normalize do |input, output, opts|
    output.delete(:Fax) unless opts[:opts][:has_fax]
    output
  end

  map from('name'),  to('Name')
  map from('industry'),  to('Industry')
  map from('annual_revenue'), to('AnnualRevenue')
  map from('number_of_employees'), to('NumberOfEmployees')

  map from('address/billing/line1'), to('BillingStreet')
  map from('address/billing/city'), to('BillingCity')
  map from('address/billing/region'), to('BillingState')
  map from('address/billing/postal_code'), to('BillingPostalCode')
  map from('address/billing/country'), to('BillingCountry')

  map from('address/shipping/line1'), to('ShippingStreet')
  map from('address/shipping/city'), to('ShippingCity')
  map from('address/shipping/region'), to('ShippingState')
  map from('address/shipping/postal_code'), to('ShippingPostalCode')
  map from('address/shipping/country'), to('ShippingCountry')

  map from('website/url'), to('Website')
  map from('phone/landline'), to('Phone')
  map from('phone/fax'), to('Fax')
end
