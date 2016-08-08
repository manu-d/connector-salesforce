class Entities::SubEntities::ContactMapper
  extend HashMapper

  after_denormalize do |input, output|
    output[:opts] = {'create_default_organization' => true}
    output
  end

  map from('title'), to('Salutation')
  map from('first_name'), to('FirstName')
  map from('last_name'), to('LastName'), default: 'Undefined'
  map from('job_title'), to('Title')
  map from('birth_date') { |d| d.to_time.iso8601 }, to('Birthdate')
  map from('organization_id'), to('AccountId')

  map from('address_work/billing/line1'), to('MailingStreet')
  map from('address_work/billing/city'), to('MailingCity')
  map from('address_work/billing/region'), to('MailingState')
  map from('address_work/billing/postal_code'), to('MailingPostalCode')
  map from('address_work/billing/country'), to('MailingCountry')

  map from('address_work/billing2/line1'), to('OtherStreet')
  map from('address_work/billing2/city'), to('OtherCity')
  map from('address_work/billing2/region'), to('OtherState')
  map from('address_work/billing2/postal_code'), to('OtherPostalCode')
  map from('address_work/billing2/country'), to('OtherCountry')

  map from('email/address'), to('Email')

  map from('phone_work/landline'), to('Phone')
  map from('phone_work/landline2'), to('OtherPhone')
  map from('phone_work/mobile'), to('MobilePhone')
  map from('phone_work/fax'), to('Fax')

  map from('phone_home/landline'), to('HomePhone')

  map from('lead_source'), to('LeadSource')
end